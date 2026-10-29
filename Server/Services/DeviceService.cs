using Microsoft.EntityFrameworkCore;
using Server.Data;
using Server.DTOs;
using Server.Helpers;
using Server.Models;

namespace Server.Services
{
    public interface IDeviceService
    {
        Task<PagedResponse<DeviceDto>> GetDevicesAsync(int pageNumber, int pageSize, string? search, string? category, int? minAge, int? maxAge);
        Task<DeviceDto?> GetDeviceByIdAsync(int id);
        Task<DeviceDto> CreateDeviceAsync(CreateDeviceDto createDto, int userId);
        Task<DeviceDto> UpdateDeviceAsync(int id, UpdateDeviceDto updateDto, int userId);
        Task<bool> DeleteDeviceAsync(int id, int userId);
    }

    public class DeviceService : IDeviceService
    {
        private readonly ApplicationDbContext _context;

        public DeviceService(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<PagedResponse<DeviceDto>> GetDevicesAsync(
            int pageNumber, int pageSize, string? search, string? category, int? minAge, int? maxAge)
        {
            var query = _context.Devices
                .Include(d => d.Reviews)
                .AsQueryable();

            // Apply filters
            if (!string.IsNullOrWhiteSpace(search))
            {
                query = query.Where(d => d.Name.Contains(search) || 
                    (d.Description != null && d.Description.Contains(search)));
            }

            if (!string.IsNullOrWhiteSpace(category) && Enum.TryParse<DeviceCategory>(category, out var categoryEnum))
            {
                query = query.Where(d => d.Category == categoryEnum);
            }

            if (minAge.HasValue)
            {
                query = query.Where(d => d.MaxAge >= minAge.Value);
            }

            if (maxAge.HasValue)
            {
                query = query.Where(d => d.MinAge <= maxAge.Value);
            }

            var totalCount = await query.CountAsync();

            var devices = await query
                .OrderByDescending(d => d.CreatedAt)
                .Skip((pageNumber - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            var deviceDtos = devices.Select(MapToDeviceDto).ToList();

            return new PagedResponse<DeviceDto>
            {
                Items = deviceDtos,
                TotalCount = totalCount,
                PageNumber = pageNumber,
                PageSize = pageSize
            };
        }

        public async Task<DeviceDto?> GetDeviceByIdAsync(int id)
        {
            var device = await _context.Devices
                .Include(d => d.Reviews)
                .FirstOrDefaultAsync(d => d.Id == id);

            return device != null ? MapToDeviceDto(device) : null;
        }

        public async Task<DeviceDto> CreateDeviceAsync(CreateDeviceDto createDto, int userId)
        {
            if (string.IsNullOrWhiteSpace(createDto.Name))
            {
                throw new ArgumentException("Tên thiết bị không được để trống");
            }

            if (!Enum.TryParse<DeviceCategory>(createDto.Category, true, out var category))
            {
                throw new ArgumentException("Danh mục thiết bị không hợp lệ");
            }

            if (createDto.Price < 0)
            {
                throw new ArgumentException("Giá thiết bị không được âm");
            }

            if (createDto.StockQuantity < 0)
            {
                throw new ArgumentException("Số lượng tồn kho không được âm");
            }

            if (createDto.MinAge < 0 || createDto.MaxAge < createDto.MinAge)
            {
                throw new ArgumentException("Độ tuổi tối đa phải lớn hơn hoặc bằng độ tuổi tối thiểu");
            }

            var userExists = await _context.Users.AnyAsync(u => u.Id == userId);
            if (!userExists)
            {
                var fallbackUser = await _context.Users
                    .OrderByDescending(u => u.Role == UserRole.Admin)
                    .FirstOrDefaultAsync();
                if (fallbackUser != null)
                {
                    userId = fallbackUser.Id;
                }
            }

            var device = new Device
            {
                Name = createDto.Name.Trim(),
                Description = createDto.Description?.Trim(),
                Category = category,
                Price = createDto.Price,
                Brand = createDto.Brand?.Trim(),
                ModelNumber = createDto.ModelNumber?.Trim(),
                ImageUrl = string.IsNullOrWhiteSpace(createDto.ImageUrl) ? null : createDto.ImageUrl.Trim(),
                StockQuantity = createDto.StockQuantity,
                MinAge = createDto.MinAge,
                MaxAge = createDto.MaxAge,
                IsAvailable = createDto.StockQuantity > 0,
                CreatedBy = userId,
                CreatedAt = DateTime.UtcNow
            };

            _context.Devices.Add(device);
            await _context.SaveChangesAsync();

            return MapToDeviceDto(device);
        }

        public async Task<DeviceDto> UpdateDeviceAsync(int id, UpdateDeviceDto updateDto, int userId)
        {
            var device = await _context.Devices
                .Include(d => d.Reviews)
                .FirstOrDefaultAsync(d => d.Id == id);

            if (device == null)
            {
                throw new KeyNotFoundException("Không tìm thấy thiết bị");
            }

            // Update fields if provided
            if (!string.IsNullOrWhiteSpace(updateDto.Name))
                device.Name = updateDto.Name.Trim();

            if (updateDto.Description != null)
                device.Description = updateDto.Description.Trim();

            if (!string.IsNullOrWhiteSpace(updateDto.Category))
            {
                if (!Enum.TryParse<DeviceCategory>(updateDto.Category, true, out var category))
                {
                    throw new ArgumentException("Danh mục thiết bị không hợp lệ");
                }
                device.Category = category;
            }

            if (updateDto.Price.HasValue)
            {
                if (updateDto.Price.Value < 0)
                {
                    throw new ArgumentException("Giá thiết bị không được âm");
                }
                device.Price = updateDto.Price.Value;
            }

            if (updateDto.Brand != null)
                device.Brand = updateDto.Brand.Trim();

            if (updateDto.ModelNumber != null)
                device.ModelNumber = updateDto.ModelNumber.Trim();

            if (updateDto.ImageUrl != null)
                device.ImageUrl = string.IsNullOrWhiteSpace(updateDto.ImageUrl) ? null : updateDto.ImageUrl.Trim();

            if (updateDto.StockQuantity.HasValue)
            {
                if (updateDto.StockQuantity.Value < 0)
                {
                    throw new ArgumentException("Số lượng tồn kho không được âm");
                }
                device.StockQuantity = updateDto.StockQuantity.Value;
            }

            if (updateDto.MinAge.HasValue)
            {
                if (updateDto.MinAge.Value < 0)
                {
                    throw new ArgumentException("Độ tuổi tối thiểu không được âm");
                }
                device.MinAge = updateDto.MinAge.Value;
            }

            if (updateDto.MaxAge.HasValue)
                device.MaxAge = updateDto.MaxAge.Value;

            if (device.MaxAge < device.MinAge)
            {
                throw new ArgumentException("Độ tuổi tối đa phải lớn hơn hoặc bằng độ tuổi tối thiểu");
            }

            if (updateDto.IsAvailable.HasValue)
                device.IsAvailable = updateDto.IsAvailable.Value;

            device.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            return MapToDeviceDto(device);
        }

        public async Task<bool> DeleteDeviceAsync(int id, int userId)
        {
            var device = await _context.Devices
                .Include(d => d.OrderItems)
                .Include(d => d.Reviews)
                .FirstOrDefaultAsync(d => d.Id == id);

            if (device == null)
            {
                return false;
            }

            if (device.OrderItems.Any())
            {
                _context.OrderItems.RemoveRange(device.OrderItems);
            }

            if (device.Reviews.Any())
            {
                _context.Reviews.RemoveRange(device.Reviews);
            }

            _context.Devices.Remove(device);
            await _context.SaveChangesAsync();

            return true;
        }

        private static DeviceDto MapToDeviceDto(Device device)
        {
            var reviews = device.Reviews?.ToList() ?? new List<Review>();
            var averageRating = reviews.Any() ? reviews.Average(r => r.Rating) : 0;

            return new DeviceDto
            {
                Id = device.Id,
                Name = device.Name,
                Description = device.Description,
                Category = device.Category.ToString(),
                Price = device.Price,
                Brand = device.Brand,
                ModelNumber = device.ModelNumber,
                ImageUrl = device.ImageUrl,
                StockQuantity = device.StockQuantity,
                MinAge = device.MinAge,
                MaxAge = device.MaxAge,
                IsAvailable = device.IsAvailable,
                AverageRating = averageRating,
                ReviewCount = reviews.Count,
                CreatedAt = device.CreatedAt
            };
        }
    }
}
