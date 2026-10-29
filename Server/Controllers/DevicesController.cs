using Microsoft.AspNetCore.Authorization;
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
        [Authorize(Roles = "Admin,Staff")]
        [ProducesResponseType(typeof(ApiResponse<DeviceDto>), StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        public async Task<IActionResult> CreateDevice([FromBody] CreateDeviceDto createDto)
        {
            var userId = _jwtHelper.GetUserIdFromToken(User);
            if (userId == null)
            {
                return Unauthorized(ApiResponse<object>.ErrorResponse("Invalid token"));
            }

            try
            {
                var device = await _deviceService.CreateDeviceAsync(createDto, userId.Value);
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
        [Authorize(Roles = "Admin,Staff")]
        [ProducesResponseType(typeof(ApiResponse<DeviceDto>), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status404NotFound)]
        public async Task<IActionResult> UpdateDevice(int id, [FromBody] UpdateDeviceDto updateDto)
        {
            var userId = _jwtHelper.GetUserIdFromToken(User);
            if (userId == null)
            {
                return Unauthorized(ApiResponse<object>.ErrorResponse("Invalid token"));
            }

            try
            {
                var device = await _deviceService.UpdateDeviceAsync(id, updateDto, userId.Value);
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
        [Authorize(Roles = "Admin")]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status404NotFound)]
        public async Task<IActionResult> DeleteDevice(int id)
        {
            var userId = _jwtHelper.GetUserIdFromToken(User);
            if (userId == null)
            {
                return Unauthorized(ApiResponse<object>.ErrorResponse("Invalid token"));
            }

            var result = await _deviceService.DeleteDeviceAsync(id, userId.Value);
            if (!result)
            {
                return NotFound(ApiResponse<object>.ErrorResponse("Device not found"));
            }

            return Ok(ApiResponse<object>.SuccessResponse(null, "Device deleted successfully"));
        }
    }
}
