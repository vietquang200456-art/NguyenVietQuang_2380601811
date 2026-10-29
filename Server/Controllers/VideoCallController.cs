using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Server.DTOs;
using Server.Helpers;
using Server.Services;

namespace Server.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class VideoCallController : ControllerBase
    {
        private readonly IVideoCallService _videoCallService;
        private readonly IAuthService _authService;

        public VideoCallController(IVideoCallService videoCallService, IAuthService authService)
        {
            _videoCallService = videoCallService;
            _authService = authService;
        }

        /// <summary>
        /// Kiểm tra thông tin người gọi và đảm bảo CHỈ User và Staff mới được phép sử dụng chức năng gọi điện.
        /// Admin hoàn toàn không có quyền gọi điện.
        /// </summary>
        private async Task<(bool Allowed, int UserId, string UserRole, string UserName, IActionResult? ErrorResult)> ValidateCallAccessAsync()
        {
            int userId = 0;
            string? role = null;
            string userName = "Người dùng";

            // 1. Lấy từ JWT Claims nếu có token JWT hợp lệ
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

            // 2. Đồng bộ với Header từ Mobile Client (hỗ trợ cả khi chuyển đổi Role trực tiếp hoặc phiên trải nghiệm)
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

            // Kiểm tra xác thực tối thiểu (JWT hoặc Bearer token phiên Mobile)
            if (User.Identity?.IsAuthenticated != true && string.IsNullOrWhiteSpace(authHeader) && string.IsNullOrWhiteSpace(headerRole))
            {
                return (false, 0, "", "", Unauthorized(ApiResponse<object>.ErrorResponse("Vui lòng đăng nhập để sử dụng tính năng gọi điện")));
            }

            if (userId <= 0)
            {
                userId = string.Equals(role, "Staff", StringComparison.OrdinalIgnoreCase) ? 2 : 3;
            }

            var normalizedRole = (role ?? "User").Trim();

            // Chặn hoàn toàn quyền gọi điện đối với ADMIN
            if (string.Equals(normalizedRole, "Admin", StringComparison.OrdinalIgnoreCase))
            {
                return (
                    false,
                    userId,
                    "Admin",
                    userName,
                    StatusCode(
                        StatusCodes.Status403Forbidden,
                        ApiResponse<object>.ErrorResponse("Tài khoản Admin không có chức năng gọi điện. Chức năng gọi điện chỉ dành cho User và Staff.")
                    )
                );
            }

            // Chỉ cho phép User và Staff
            if (!string.Equals(normalizedRole, "User", StringComparison.OrdinalIgnoreCase) &&
                !string.Equals(normalizedRole, "Staff", StringComparison.OrdinalIgnoreCase))
            {
                return (
                    false,
                    userId,
                    normalizedRole,
                    userName,
                    StatusCode(
                        StatusCodes.Status403Forbidden,
                        ApiResponse<object>.ErrorResponse("Chỉ tài khoản User và Staff mới được phép sử dụng chức năng gọi điện.")
                    )
                );
            }

            var canonicalRole = string.Equals(normalizedRole, "Staff", StringComparison.OrdinalIgnoreCase)
                ? "Staff"
                : "User";

            return (true, userId, canonicalRole, userName, null);
        }

        [HttpGet("rooms")]
        [ProducesResponseType(typeof(ApiResponse<List<VideoCallRoomDto>>), StatusCodes.Status200OK)]
        public async Task<IActionResult> GetActiveRooms()
        {
            var access = await ValidateCallAccessAsync();
            if (!access.Allowed)
                return access.ErrorResult!;

            var rooms = await _videoCallService.GetActiveRoomsAsync();
            return Ok(ApiResponse<List<VideoCallRoomDto>>.SuccessResponse(rooms, "Lấy danh sách phòng gọi thành công"));
        }

        [HttpPost("create-room")]
        [ProducesResponseType(typeof(ApiResponse<VideoCallRoomDto>), StatusCodes.Status201Created)]
        public async Task<IActionResult> CreateRoom([FromBody] CreateRoomDto dto)
        {
            var access = await ValidateCallAccessAsync();
            if (!access.Allowed)
                return access.ErrorResult!;

            try
            {
                var room = await _videoCallService.CreateRoomAsync(
                    dto.RoomName,
                    dto.MaxParticipants,
                    dto.CallType,
                    dto.Description,
                    access.UserId,
                    access.UserName,
                    access.UserRole);

                return CreatedAtAction(nameof(GetRoomInfo), new { roomName = room.RoomName },
                    ApiResponse<VideoCallRoomDto>.SuccessResponse(room, "Khởi tạo phòng gọi thành công"));
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ApiResponse<object>.ErrorResponse(ex.Message));
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(ApiResponse<object>.ErrorResponse(ex.Message));
            }
        }

        [HttpPost("join")]
        [ProducesResponseType(typeof(ApiResponse<VideoCallTokenDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> JoinRoom([FromBody] JoinRoomDto dto)
        {
            var access = await ValidateCallAccessAsync();
            if (!access.Allowed)
                return access.ErrorResult!;

            try
            {
                var participantName = string.IsNullOrWhiteSpace(dto.ParticipantName)
                    ? access.UserName
                    : dto.ParticipantName;

                var token = await _videoCallService.GenerateTokenAsync(
                    dto.RoomName,
                    participantName,
                    access.UserId,
                    access.UserRole,
                    dto.IsAudioOnly);

                return Ok(ApiResponse<VideoCallTokenDto>.SuccessResponse(token, "Tạo token kết nối cuộc gọi thành công"));
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

        [HttpPost("leave")]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status200OK)]
        public async Task<IActionResult> LeaveRoom([FromBody] LeaveRoomDto dto)
        {
            var access = await ValidateCallAccessAsync();
            if (!access.Allowed)
                return access.ErrorResult!;

            await _videoCallService.LeaveRoomAsync(dto.RoomName, access.UserId, access.UserRole);
            return Ok(ApiResponse<object>.SuccessResponse(null, "Đã rời khỏi phòng gọi"));
        }

        [HttpGet("rooms/{roomName}")]
        [ProducesResponseType(typeof(ApiResponse<VideoCallRoomDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> GetRoomInfo(string roomName)
        {
            var access = await ValidateCallAccessAsync();
            if (!access.Allowed)
                return access.ErrorResult!;

            var room = await _videoCallService.GetRoomInfoAsync(roomName);
            if (room == null)
                return NotFound(ApiResponse<object>.ErrorResponse("Không tìm thấy phòng gọi"));

            return Ok(ApiResponse<VideoCallRoomDto>.SuccessResponse(room));
        }

        [HttpGet("rooms/{roomName}/participants")]
        [ProducesResponseType(typeof(ApiResponse<List<ParticipantDto>>), StatusCodes.Status200OK)]
        public async Task<IActionResult> GetParticipants(string roomName)
        {
            var access = await ValidateCallAccessAsync();
            if (!access.Allowed)
                return access.ErrorResult!;

            try
            {
                var participants = await _videoCallService.GetParticipantsAsync(roomName);
                return Ok(ApiResponse<List<ParticipantDto>>.SuccessResponse(participants));
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(ApiResponse<object>.ErrorResponse(ex.Message));
            }
        }

        [HttpDelete("rooms/{roomName}")]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status200OK)]
        public async Task<IActionResult> EndRoom(string roomName)
        {
            var access = await ValidateCallAccessAsync();
            if (!access.Allowed)
                return access.ErrorResult!;

            var ended = await _videoCallService.EndRoomAsync(roomName);
            if (!ended)
                return NotFound(ApiResponse<object>.ErrorResponse("Không tìm thấy phòng gọi"));

            return Ok(ApiResponse<object>.SuccessResponse(null, "Đã kết thúc phòng gọi"));
        }
    }
}
