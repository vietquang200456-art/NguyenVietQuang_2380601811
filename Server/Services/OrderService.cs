using Microsoft.EntityFrameworkCore;
using Server.Data;
using Server.DTOs;
using Server.Helpers;
using Server.Models;

namespace Server.Services
{
    public interface IOrderService
    {
        Task<PagedResponse<OrderDto>> GetOrdersAsync(int pageNumber, int pageSize, int? userId, string? status);
        Task<OrderDto?> GetOrderByIdAsync(int id, int userId, bool isAdmin);
        Task<OrderDto> CreateOrderAsync(CreateOrderDto createDto, int userId);
        Task<OrderDto> UpdateOrderStatusAsync(int id, UpdateOrderStatusDto updateDto, int userId);
        Task<bool> CancelOrderAsync(int id, int userId);
    }

    public class OrderService : IOrderService
    {
        private readonly ApplicationDbContext _context;
        private readonly IEmailService _emailService;

        public OrderService(ApplicationDbContext context, IEmailService emailService)
        {
            _context = context;            _emailService = emailService;
        }

        public async Task<PagedResponse<OrderDto>> GetOrdersAsync(
            int pageNumber, int pageSize, int? userId, string? status)
        {
            var query = _context.Orders
                .Include(o => o.User)
                .Include(o => o.OrderItems)
                    .ThenInclude(oi => oi.Device)
                .AsQueryable();

            if (userId.HasValue)
            {
                query = query.Where(o => o.UserId == userId.Value);
            }

            if (!string.IsNullOrWhiteSpace(status) && Enum.TryParse<OrderStatus>(status, out var statusEnum))
            {
                query = query.Where(o => o.Status == statusEnum);
            }

            var totalCount = await query.CountAsync();

            var orders = await query
                .OrderByDescending(o => o.CreatedAt)
                .Skip((pageNumber - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            var orderDtos = orders.Select(MapToOrderDto).ToList();

            return new PagedResponse<OrderDto>
            {
                Items = orderDtos,
                TotalCount = totalCount,
                PageNumber = pageNumber,
                PageSize = pageSize
            };
        }

        public async Task<OrderDto?> GetOrderByIdAsync(int id, int userId, bool isAdmin)
        {
            var query = _context.Orders
                .Include(o => o.User)
                .Include(o => o.OrderItems)
                    .ThenInclude(oi => oi.Device)
                .Where(o => o.Id == id);

            if (!isAdmin)
            {
                query = query.Where(o => o.UserId == userId);
            }

            var order = await query.FirstOrDefaultAsync();

            return order != null ? MapToOrderDto(order) : null;
        }

        public async Task<OrderDto> CreateOrderAsync(CreateOrderDto createDto, int userId)
        {
            if (!createDto.Items.Any())
            {
                throw new ArgumentException("Order must contain at least one item");
            }

            using var transaction = await _context.Database.BeginTransactionAsync();

            try
            {
                // Validate and get devices
                var deviceIds = createDto.Items.Select(i => i.DeviceId).ToList();
                var devices = await _context.Devices
                    .Where(d => deviceIds.Contains(d.Id))
                    .ToListAsync();

                if (devices.Count != deviceIds.Count)
                {
                    throw new ArgumentException("One or more devices not found");
                }

                // Check stock availability
                foreach (var item in createDto.Items)
                {
                    var device = devices.First(d => d.Id == item.DeviceId);
                    if (device.StockQuantity < item.Quantity)
                    {
                        throw new InvalidOperationException($"Insufficient stock for device: {device.Name}");
                    }
                    if (!device.IsAvailable)
                    {
                        throw new InvalidOperationException($"Device is not available: {device.Name}");
                    }
                }

                // Create order
                var order = new Order
                {
                    OrderNumber = GenerateOrderNumber(),
                    UserId = userId,
                    ShippingAddress = createDto.ShippingAddress,
                    PhoneNumber = createDto.PhoneNumber,
                    Notes = createDto.Notes,
                    Status = OrderStatus.Pending,
                    CreatedAt = DateTime.UtcNow
                };

                _context.Orders.Add(order);
                await _context.SaveChangesAsync();

                // Create order items and update stock
                decimal totalAmount = 0;
                foreach (var item in createDto.Items)
                {
                    var device = devices.First(d => d.Id == item.DeviceId);
                    var orderItem = new OrderItem
                    {
                        OrderId = order.Id,
                        DeviceId = device.Id,
                        Quantity = item.Quantity,
                        UnitPrice = device.Price,
                        TotalPrice = device.Price * item.Quantity
                    };

                    _context.OrderItems.Add(orderItem);
                    totalAmount += orderItem.TotalPrice;

                    // Update stock
                    device.StockQuantity -= item.Quantity;
                    device.UpdatedAt = DateTime.UtcNow;
                }

                order.TotalAmount = totalAmount;
                await _context.SaveChangesAsync();

                await transaction.CommitAsync();

                // Reload order with includes
                var createdOrder = await _context.Orders
                    .Include(o => o.User)
                    .Include(o => o.OrderItems)
                        .ThenInclude(oi => oi.Device)
                    .FirstAsync(o => o.Id == order.Id);

                var orderDto = MapToOrderDto(createdOrder);
                await _emailService.SendOrderConfirmationAsync(createdOrder.User?.Email ?? string.Empty, orderDto);

                return orderDto;
            }
            catch
            {
                await transaction.RollbackAsync();
                throw;
            }
        }

        public async Task<OrderDto> UpdateOrderStatusAsync(int id, UpdateOrderStatusDto updateDto, int userId)
        {
            if (!Enum.TryParse<OrderStatus>(updateDto.Status, out var newStatus))
            {
                throw new ArgumentException("Invalid status");
            }

            var order = await _context.Orders
                .Include(o => o.User)
                .Include(o => o.OrderItems)
                    .ThenInclude(oi => oi.Device)
                .FirstOrDefaultAsync(o => o.Id == id);

            if (order == null)
            {
                throw new KeyNotFoundException("Order not found");
            }

            order.Status = newStatus;
            order.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            return MapToOrderDto(order);
        }

        public async Task<bool> CancelOrderAsync(int id, int userId)
        {
            var order = await _context.Orders
                .Include(o => o.OrderItems)
                    .ThenInclude(oi => oi.Device)
                .FirstOrDefaultAsync(o => o.Id == id && o.UserId == userId);

            if (order == null)
            {
                return false;
            }

            if (order.Status != OrderStatus.Pending && order.Status != OrderStatus.Confirmed)
            {
                throw new InvalidOperationException("Can only cancel pending or confirmed orders");
            }

            using var transaction = await _context.Database.BeginTransactionAsync();

            try
            {
                // Restore stock
                foreach (var item in order.OrderItems)
                {
                    item.Device!.StockQuantity += item.Quantity;
                    item.Device.UpdatedAt = DateTime.UtcNow;
                }

                order.Status = OrderStatus.Cancelled;
                order.UpdatedAt = DateTime.UtcNow;

                await _context.SaveChangesAsync();
                await transaction.CommitAsync();

                return true;
            }
            catch
            {
                await transaction.RollbackAsync();
                throw;
            }
        }

        private static string GenerateOrderNumber()
        {
            return $"ORD{DateTime.UtcNow:yyyyMMddHHmmss}{new Random().Next(1000, 9999)}";
        }

        private static OrderDto MapToOrderDto(Order order)
        {
            return new OrderDto
            {
                Id = order.Id,
                OrderNumber = order.OrderNumber,
                UserId = order.UserId,
                UserName = order.User?.FullName ?? "",
                TotalAmount = order.TotalAmount,
                Status = order.Status.ToString(),
                ShippingAddress = order.ShippingAddress,
                PhoneNumber = order.PhoneNumber,
                Notes = order.Notes,
                CreatedAt = order.CreatedAt,
                Items = order.OrderItems.Select(oi => new OrderItemDto
                {
                    Id = oi.Id,
                    DeviceId = oi.DeviceId,
                    DeviceName = oi.Device?.Name ?? "",
                    Quantity = oi.Quantity,
                    UnitPrice = oi.UnitPrice,
                    TotalPrice = oi.TotalPrice
                }).ToList()
            };
        }
    }
}



