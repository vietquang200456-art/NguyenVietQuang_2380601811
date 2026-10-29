using System.Security.Claims;
using Microsoft.AspNetCore.Mvc;
using Server.DTOs;
using Server.Helpers;
using Server.Services;

namespace Server.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class LocationController : ControllerBase
    {
        private readonly ILocationService _locationService;
        private readonly IAuthService _authService;

        public LocationController(ILocationService locationService, IAuthService authService)
        {
            _locationService = locationService;
            _authService = authService;
        }

        /// <summary>
        /// Kiểm tra quyền truy cập và đảm bảo CHỈ tài khoản User (Phụ huynh / Người dùng)
        /// mới được phép sử dụng tính năng Chia sẻ vị trí.
        /// </summary>
        private async Task<(bool Allowed, int UserId, string UserRole, string UserName, IActionResult? ErrorResult)> ValidateUserLocationAccessAsync()
        {
            int userId = 0;
            string? role = null;
            string userName = "Phụ huynh (User)";

            if (User.Identity?.IsAuthenticated == true)
            {
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (int.TryParse(userIdClaim, out var parsedId))
                {
                    userId = parsedId;
                }

                role = User.FindFirst(ClaimTypes.Role)?.Value;
                userName = User.FindFirst(ClaimTypes.Name)?.Value ?? userName;

                if (userId > 0)
                {
                    var dbUser = await _authService.GetUserByIdAsync(userId);
                    if (dbUser != null)
                    {
                        role = dbUser.Role;
                        if (!string.IsNullOrWhiteSpace(dbUser.FullName))
                            userName = dbUser.FullName;
                    }
                }
            }

            var headerRole = Request.Headers["X-User-Role"].FirstOrDefault();
            var headerUserId = Request.Headers["X-User-Id"].FirstOrDefault();
            var headerUserName = Request.Headers["X-User-Name"].FirstOrDefault();
            var authHeader = Request.Headers.Authorization.FirstOrDefault();

            if (!string.IsNullOrWhiteSpace(headerRole))
            {
                role = headerRole.Trim();
            }

            if (userId == 0 && !string.IsNullOrWhiteSpace(headerUserId) && int.TryParse(headerUserId, out var hId))
            {
                userId = hId;
            }

            if (!string.IsNullOrWhiteSpace(headerUserName))
            {
                userName = Uri.UnescapeDataString(headerUserName.Trim());
            }

            if (User.Identity?.IsAuthenticated != true && string.IsNullOrWhiteSpace(authHeader) && string.IsNullOrWhiteSpace(headerRole))
            {
                return (
                    false,
                    0,
                    "",
                    "",
                    Unauthorized(ApiResponse<object>.ErrorResponse("Vui lòng đăng nhập tài khoản User để sử dụng tính năng Chia sẻ vị trí."))
                );
            }

            var normalizedRole = (role ?? "User").Trim();

            if (!string.Equals(normalizedRole, "User", StringComparison.OrdinalIgnoreCase))
            {
                return (
                    false,
                    userId,
                    normalizedRole,
                    userName,
                    StatusCode(
                        StatusCodes.Status403Forbidden,
                        ApiResponse<object>.ErrorResponse($"Tính năng Chia sẻ vị trí là chức năng dành riêng cho User (Phụ huynh). Tài khoản {normalizedRole} không sử dụng chức năng này.")
                    )
                );
            }

            if (userId <= 0)
            {
                userId = 1;
            }

            return (true, userId, "User", userName, null);
        }

        [HttpGet("dashboard")]
        [ProducesResponseType(typeof(ApiResponse<UserLocationDashboardDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> GetDashboard([FromQuery] double? lat, [FromQuery] double? lng)
        {
            var access = await ValidateUserLocationAccessAsync();
            if (!access.Allowed)
                return access.ErrorResult!;

            var dashboard = await _locationService.GetUserDashboardAsync(access.UserId, lat, lng);
            return Ok(ApiResponse<UserLocationDashboardDto>.SuccessResponse(dashboard, "Lấy dữ liệu định vị & chia sẻ vị trí thành công"));
        }

        [HttpPost("share")]
        [ProducesResponseType(typeof(ApiResponse<SharedLocationDto>), StatusCodes.Status201Created)]
        public async Task<IActionResult> ShareLocation([FromBody] ShareLocationRequestDto dto)
        {
            var access = await ValidateUserLocationAccessAsync();
            if (!access.Allowed)
                return access.ErrorResult!;

            try
            {
                var shared = await _locationService.ShareLocationAsync(
                    access.UserId,
                    access.UserName,
                    access.UserRole,
                    dto);

                return StatusCode(
                    StatusCodes.Status201Created,
                    ApiResponse<SharedLocationDto>.SuccessResponse(shared, "Đã chia sẻ vị trí chính xác của bạn thành công")
                );
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ApiResponse<object>.ErrorResponse(ex.Message));
            }
        }

        [HttpPut("live")]
        [ProducesResponseType(typeof(ApiResponse<SharedLocationDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> UpdateLiveLocation([FromBody] UpdateLiveLocationDto dto)
        {
            var access = await ValidateUserLocationAccessAsync();
            if (!access.Allowed)
                return access.ErrorResult!;

            try
            {
                var updated = await _locationService.UpdateLiveLocationAsync(access.UserId, dto);
                if (updated == null)
                {
                    return NotFound(ApiResponse<object>.ErrorResponse("Không tìm thấy phiên chia sẻ vị trí trực tiếp đang hoạt động"));
                }

                return Ok(ApiResponse<SharedLocationDto>.SuccessResponse(updated, "Đã cập nhật tọa độ Live GPS thành công"));
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ApiResponse<object>.ErrorResponse(ex.Message));
            }
        }

        [HttpPost("stop-live")]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status200OK)]
        public async Task<IActionResult> StopLiveLocation([FromQuery] string? shareCode = null)
        {
            var access = await ValidateUserLocationAccessAsync();
            if (!access.Allowed)
                return access.ErrorResult!;

            await _locationService.StopLiveLocationAsync(access.UserId, shareCode);
            return Ok(ApiResponse<object>.SuccessResponse(null, "Đã dừng chia sẻ vị trí trực tiếp"));
        }

        [HttpGet("code/{shareCode}")]
        [ProducesResponseType(typeof(ApiResponse<SharedLocationDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> GetByShareCode(string shareCode)
        {
            var access = await ValidateUserLocationAccessAsync();
            if (!access.Allowed)
                return access.ErrorResult!;

            var found = await _locationService.GetSharedLocationByCodeAsync(shareCode);
            if (found == null)
            {
                return NotFound(ApiResponse<object>.ErrorResponse("Không tìm thấy mã chia sẻ vị trí này"));
            }

            return Ok(ApiResponse<SharedLocationDto>.SuccessResponse(found));
        }

        [HttpDelete("{id}")]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status200OK)]
        public async Task<IActionResult> DeleteSharedLocation(string id)
        {
            var access = await ValidateUserLocationAccessAsync();
            if (!access.Allowed)
                return access.ErrorResult!;

            var deleted = await _locationService.DeleteSharedLocationAsync(access.UserId, id);
            if (!deleted)
            {
                return NotFound(ApiResponse<object>.ErrorResponse("Không tìm thấy bản ghi vị trí cần xóa"));
            }

            return Ok(ApiResponse<object>.SuccessResponse(null, "Đã xóa lịch sử chia sẻ vị trí"));
        }
    }
}

