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
            if (!Enum.TryParse<DeviceCategory>(createDto.Category, out var category))
            {
                throw new ArgumentException("Invalid category");
            }

            var device = new Device
            {
                Name = createDto.Name,
                Description = createDto.Description,
                Category = category,
                Price = createDto.Price,
                Brand = createDto.Brand,
                ModelNumber = createDto.ModelNumber,
                ImageUrl = createDto.ImageUrl,
                StockQuantity = createDto.StockQuantity,
                MinAge = createDto.MinAge,
                MaxAge = createDto.MaxAge,
                IsAvailable = true,
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
                throw new KeyNotFoundException("Device not found");
            }

            // Update fields if provided
            if (!string.IsNullOrWhiteSpace(updateDto.Name))
                device.Name = updateDto.Name;

            if (updateDto.Description != null)
                device.Description = updateDto.Description;

            if (!string.IsNullOrWhiteSpace(updateDto.Category) && 
                Enum.TryParse<DeviceCategory>(updateDto.Category, out var category))
                device.Category = category;

            if (updateDto.Price.HasValue)
                device.Price = updateDto.Price.Value;

            if (updateDto.Brand != null)
                device.Brand = updateDto.Brand;

            if (updateDto.ModelNumber != null)
                device.ModelNumber = updateDto.ModelNumber;

            if (updateDto.ImageUrl != null)
                device.ImageUrl = updateDto.ImageUrl;

            if (updateDto.StockQuantity.HasValue)
                device.StockQuantity = updateDto.StockQuantity.Value;

            if (updateDto.MinAge.HasValue)
                device.MinAge = updateDto.MinAge.Value;

            if (updateDto.MaxAge.HasValue)
                device.MaxAge = updateDto.MaxAge.Value;

            if (updateDto.IsAvailable.HasValue)
                device.IsAvailable = updateDto.IsAvailable.Value;

            device.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            return MapToDeviceDto(device);
        }

        public async Task<bool> DeleteDeviceAsync(int id, int userId)
        {
            var device = await _context.Devices.FindAsync(id);

            if (device == null)
            {
                return false;
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
