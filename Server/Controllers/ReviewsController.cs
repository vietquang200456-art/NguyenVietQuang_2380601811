using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Server.DTOs;
using Server.Helpers;
using Server.Services;

namespace Server.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ReviewsController : ControllerBase
    {
        private readonly IReviewService _reviewService;
        private readonly JwtHelper _jwtHelper;

        public ReviewsController(IReviewService reviewService, JwtHelper jwtHelper)
        {
            _reviewService = reviewService;
            _jwtHelper = jwtHelper;
        }

        /// <summary>
        /// Get all reviews with pagination and filters
        /// </summary>
        [HttpGet]
        [ProducesResponseType(typeof(ApiResponse<PagedResponse<ReviewDto>>), StatusCodes.Status200OK)]
        public async Task<IActionResult> GetReviews(
            [FromQuery] int pageNumber = 1,
            [FromQuery] int pageSize = 10,
            [FromQuery] int? deviceId = null,
            [FromQuery] int? userId = null)
        {
            var result = await _reviewService.GetReviewsAsync(pageNumber, pageSize, deviceId, userId);
            return Ok(ApiResponse<PagedResponse<ReviewDto>>.SuccessResponse(result));
        }

        /// <summary>
        /// Get review by ID
        /// </summary>
        [HttpGet("{id}")]
        [ProducesResponseType(typeof(ApiResponse<ReviewDto>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status404NotFound)]
        public async Task<IActionResult> GetReviewById(int id)
        {
            var review = await _reviewService.GetReviewByIdAsync(id);
            if (review == null)
            {
                return NotFound(ApiResponse<object>.ErrorResponse("Review not found"));
            }

            return Ok(ApiResponse<ReviewDto>.SuccessResponse(review));
        }

        /// <summary>
        /// Create a new review
        /// </summary>
        [HttpPost]
        [Authorize]
        [ProducesResponseType(typeof(ApiResponse<ReviewDto>), StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> CreateReview([FromBody] CreateReviewDto createDto)
        {
            var userId = _jwtHelper.GetUserIdFromToken(User);
            if (userId == null)
            {
                return Unauthorized(ApiResponse<object>.ErrorResponse("Invalid token"));
            }

            try
            {
                var review = await _reviewService.CreateReviewAsync(createDto, userId.Value);
                return CreatedAtAction(nameof(GetReviewById), new { id = review.Id },
                    ApiResponse<ReviewDto>.SuccessResponse(review, "Review created successfully"));
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ApiResponse<object>.ErrorResponse(ex.Message));
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(ApiResponse<object>.ErrorResponse(ex.Message));
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(ApiResponse<object>.ErrorResponse(ex.Message));
            }
        }

        /// <summary>
        /// Update review
        /// </summary>
        [HttpPut("{id}")]
        [Authorize]
        [ProducesResponseType(typeof(ApiResponse<ReviewDto>), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status404NotFound)]
        public async Task<IActionResult> UpdateReview(int id, [FromBody] UpdateReviewDto updateDto)
        {
            var userId = _jwtHelper.GetUserIdFromToken(User);
            if (userId == null)
            {
                return Unauthorized(ApiResponse<object>.ErrorResponse("Invalid token"));
            }

            try
            {
                var review = await _reviewService.UpdateReviewAsync(id, updateDto, userId.Value);
                return Ok(ApiResponse<ReviewDto>.SuccessResponse(review, "Review updated successfully"));
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(ApiResponse<object>.ErrorResponse(ex.Message));
            }
            catch (UnauthorizedAccessException)
            {
                return Forbid();
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ApiResponse<object>.ErrorResponse(ex.Message));
            }
        }

        /// <summary>
        /// Delete review
        /// </summary>
        [HttpDelete("{id}")]
        [Authorize]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status404NotFound)]
        public async Task<IActionResult> DeleteReview(int id)
        {
            var userId = _jwtHelper.GetUserIdFromToken(User);
            var userRole = _jwtHelper.GetUserRole(User);
            
            if (userId == null)
            {
                return Unauthorized(ApiResponse<object>.ErrorResponse("Invalid token"));
            }

            try
            {
                var result = await _reviewService.DeleteReviewAsync(id, userId.Value, userRole == "Admin");
                if (!result)
                {
                    return NotFound(ApiResponse<object>.ErrorResponse("Review not found"));
                }

                return Ok(ApiResponse<object>.SuccessResponse(null, "Review deleted successfully"));
            }
            catch (UnauthorizedAccessException)
            {
                return Forbid();
            }
        }
    }
}
