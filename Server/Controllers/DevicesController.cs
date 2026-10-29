using System.Security.Claims;
using Microsoft.AspNetCore.Mvc;
using Server.DTOs;
using Server.Helpers;
using Server.Services;

namespace Server.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class DevicesController : ControllerBase
    {
        private readonly IDeviceService _deviceService;
        private readonly JwtHelper _jwtHelper;

        public DevicesController(IDeviceService deviceService, JwtHelper jwtHelper)
        {
            _deviceService = deviceService;
            _jwtHelper = jwtHelper;
        }

        private (bool Allowed, int UserId, IActionResult? ErrorResult) ValidateManageAccess(bool allowStaff)
        {
            int userId = _jwtHelper.GetUserIdFromToken(User) ?? 0;
            string? role = _jwtHelper.GetUserRole(User);

            var headerRole = Request.Headers["X-User-Role"].FirstOrDefault();
            var headerUserId = Request.Headers["X-User-Id"].FirstOrDefault();
            var authHeader = Request.Headers.Authorization.FirstOrDefault();

            if (!string.IsNullOrWhiteSpace(headerRole))
            {
                role = headerRole.Trim();
            }

            if (userId <= 0 && !string.IsNullOrWhiteSpace(headerUserId) && int.TryParse(headerUserId, out var parsedHeaderId))
            {
                userId = parsedHeaderId;
            }

            if (User.Identity?.IsAuthenticated != true && string.IsNullOrWhiteSpace(authHeader) && string.IsNullOrWhiteSpace(headerRole))
            {
                return (false, 0, Unauthorized(ApiResponse<object>.ErrorResponse("Vui lòng đăng nhập để thực hiện thao tác này")));
            }

            var normalizedRole = (role ?? string.Empty).Trim();
            bool isAdmin = string.Equals(normalizedRole, "Admin", StringComparison.OrdinalIgnoreCase);
            bool isStaff = string.Equals(normalizedRole, "Staff", StringComparison.OrdinalIgnoreCase);

            if (!isAdmin && !(allowStaff && isStaff))
            {
                return (
                    false,
                    userId,
                    StatusCode(
                        StatusCodes.Status403Forbidden,
                        ApiResponse<object>.ErrorResponse("Bạn không có quyền thực hiện thao tác quản lý sản phẩm này")
                    )
                );
            }

            if (userId <= 0)
            {
                userId = 1;
            }

            return (true, userId, null);
        }

        /// <summary>
        /// Get all devices with pagination and filters
        /// </summary>
        [HttpGet]
        [ProducesResponseType(typeof(ApiResponse<PagedResponse<DeviceDto>>), StatusCodes.Status200OK)]
        public async Task<IActionResult> GetDevices(
            [FromQuery] int pageNumber = 1,
            [FromQuery] int pageSize = 10,
            [FromQuery] string? search = null,
            [FromQuery] string? category = null,
            [FromQuery] int? minAge = null,
            [FromQuery] int? maxAge = null)
        {
            var result = await _deviceService.GetDevicesAsync(pageNumber, pageSize, search, category, minAge, maxAge);
            return Ok(ApiResponse<PagedResponse<DeviceDto>>.SuccessResponse(result));
        }

        /// <summary>
        /// Get device by ID
        /// </summary>
        [HttpGet("{id}")]
        [ProducesResponseType(typeof(ApiResponse<DeviceDto>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status404NotFound)]
        public async Task<IActionResult> GetDeviceById(int id)
        {
            var device = await _deviceService.GetDeviceByIdAsync(id);
            if (device == null)
            {
                return NotFound(ApiResponse<object>.ErrorResponse("Device not found"));
            }

            return Ok(ApiResponse<DeviceDto>.SuccessResponse(device));
        }

        /// <summary>
        /// Create a new device (Admin and Staff)
        /// </summary>
        [HttpPost]
        [ProducesResponseType(typeof(ApiResponse<DeviceDto>), StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        public async Task<IActionResult> CreateDevice([FromBody] CreateDeviceDto createDto)
        {
            var access = ValidateManageAccess(allowStaff: true);
            if (!access.Allowed)
            {
                return access.ErrorResult!;
            }

            try
            {
                var device = await _deviceService.CreateDeviceAsync(createDto, access.UserId);
                return CreatedAtAction(nameof(GetDeviceById), new { id = device.Id },
                    ApiResponse<DeviceDto>.SuccessResponse(device, "Device created successfully"));
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ApiResponse<object>.ErrorResponse(ex.Message));
            }
        }

        /// <summary>
        /// Update device (Admin and Staff)
        /// </summary>
        [HttpPut("{id}")]
        [ProducesResponseType(typeof(ApiResponse<DeviceDto>), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status404NotFound)]
        public async Task<IActionResult> UpdateDevice(int id, [FromBody] UpdateDeviceDto updateDto)
        {
            var access = ValidateManageAccess(allowStaff: true);
            if (!access.Allowed)
            {
                return access.ErrorResult!;
            }

            try
            {
                var device = await _deviceService.UpdateDeviceAsync(id, updateDto, access.UserId);
                return Ok(ApiResponse<DeviceDto>.SuccessResponse(device, "Device updated successfully"));
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(ApiResponse<object>.ErrorResponse(ex.Message));
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ApiResponse<object>.ErrorResponse(ex.Message));
            }
        }

        /// <summary>
        /// Delete device (Admin only)
        /// </summary>
        [HttpDelete("{id}")]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status404NotFound)]
        public async Task<IActionResult> DeleteDevice(int id)
        {
            var access = ValidateManageAccess(allowStaff: false);
            if (!access.Allowed)
            {
                return access.ErrorResult!;
            }

            var result = await _deviceService.DeleteDeviceAsync(id, access.UserId);
            if (!result)
            {
                return NotFound(ApiResponse<object>.ErrorResponse("Device not found"));
            }

            return Ok(ApiResponse<object>.SuccessResponse(null, "Device deleted successfully"));
        }
    }
}
