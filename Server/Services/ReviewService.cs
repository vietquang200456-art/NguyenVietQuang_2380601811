using Microsoft.EntityFrameworkCore;
using Server.Data;
using Server.DTOs;
using Server.Helpers;
using Server.Models;

namespace Server.Services
{
    public interface IReviewService
    {
        Task<PagedResponse<ReviewDto>> GetReviewsAsync(int pageNumber, int pageSize, int? deviceId, int? userId);
        Task<ReviewDto?> GetReviewByIdAsync(int id);
        Task<ReviewDto> CreateReviewAsync(CreateReviewDto createDto, int userId);
        Task<ReviewDto> UpdateReviewAsync(int id, UpdateReviewDto updateDto, int userId);
        Task<bool> DeleteReviewAsync(int id, int userId, bool isAdmin);
    }

    public class ReviewService : IReviewService
    {
        private readonly ApplicationDbContext _context;

        public ReviewService(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<PagedResponse<ReviewDto>> GetReviewsAsync(
            int pageNumber, int pageSize, int? deviceId, int? userId)
        {
            var query = _context.Reviews
                .Include(r => r.User)
                .Include(r => r.Device)
                .AsQueryable();

            if (deviceId.HasValue)
            {
                query = query.Where(r => r.DeviceId == deviceId.Value);
            }

            if (userId.HasValue)
            {
                query = query.Where(r => r.UserId == userId.Value);
            }

            var totalCount = await query.CountAsync();

            var reviews = await query
                .OrderByDescending(r => r.CreatedAt)
                .Skip((pageNumber - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            var reviewDtos = reviews.Select(MapToReviewDto).ToList();

            return new PagedResponse<ReviewDto>
            {
                Items = reviewDtos,
                TotalCount = totalCount,
                PageNumber = pageNumber,
                PageSize = pageSize
            };
        }

        public async Task<ReviewDto?> GetReviewByIdAsync(int id)
        {
            var review = await _context.Reviews
                .Include(r => r.User)
                .Include(r => r.Device)
                .FirstOrDefaultAsync(r => r.Id == id);

            return review != null ? MapToReviewDto(review) : null;
        }

        public async Task<ReviewDto> CreateReviewAsync(CreateReviewDto createDto, int userId)
        {
            // Validate rating
            if (createDto.Rating < 1 || createDto.Rating > 5)
            {
                throw new ArgumentException("Rating must be between 1 and 5");
            }

            // Check if device exists
            var device = await _context.Devices.FindAsync(createDto.DeviceId);
            if (device == null)
            {
                throw new KeyNotFoundException("Device not found");
            }

            // Check if user already reviewed this device
            var existingReview = await _context.Reviews
                .FirstOrDefaultAsync(r => r.UserId == userId && r.DeviceId == createDto.DeviceId);

            if (existingReview != null)
            {
                throw new InvalidOperationException("You have already reviewed this device");
            }

            var review = new Review
            {
                UserId = userId,
                DeviceId = createDto.DeviceId,
                Rating = createDto.Rating,
                Comment = createDto.Comment,
                CreatedAt = DateTime.UtcNow
            };

            _context.Reviews.Add(review);
            await _context.SaveChangesAsync();

            // Reload with includes
            var createdReview = await _context.Reviews
                .Include(r => r.User)
                .Include(r => r.Device)
                .FirstAsync(r => r.Id == review.Id);

            return MapToReviewDto(createdReview);
        }

        public async Task<ReviewDto> UpdateReviewAsync(int id, UpdateReviewDto updateDto, int userId)
        {
            var review = await _context.Reviews
                .Include(r => r.User)
                .Include(r => r.Device)
                .FirstOrDefaultAsync(r => r.Id == id);

            if (review == null)
            {
                throw new KeyNotFoundException("Review not found");
            }

            if (review.UserId != userId)
            {
                throw new UnauthorizedAccessException("You can only update your own reviews");
            }

            // Validate rating
            if (updateDto.Rating < 1 || updateDto.Rating > 5)
            {
                throw new ArgumentException("Rating must be between 1 and 5");
            }

            review.Rating = updateDto.Rating;
            review.Comment = updateDto.Comment;
            review.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            return MapToReviewDto(review);
        }

        public async Task<bool> DeleteReviewAsync(int id, int userId, bool isAdmin)
        {
            var review = await _context.Reviews.FindAsync(id);

            if (review == null)
            {
                return false;
            }

            if (!isAdmin && review.UserId != userId)
            {
                throw new UnauthorizedAccessException("You can only delete your own reviews");
            }

            _context.Reviews.Remove(review);
            await _context.SaveChangesAsync();

            return true;
        }

        private static ReviewDto MapToReviewDto(Review review)
        {
            return new ReviewDto
            {
                Id = review.Id,
                UserId = review.UserId,
                UserName = review.User?.FullName ?? "",
                DeviceId = review.DeviceId,
                DeviceName = review.Device?.Name ?? "",
                Rating = review.Rating,
                Comment = review.Comment,
                CreatedAt = review.CreatedAt
            };
        }
    }
}
