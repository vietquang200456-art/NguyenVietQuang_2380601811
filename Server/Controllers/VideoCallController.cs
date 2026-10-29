using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Server.DTOs;
using Server.Helpers;
using Server.Services;

namespace Server.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class VideoCallController : ControllerBase
    {
        private readonly IVideoCallService _videoCallService;

        public VideoCallController(IVideoCallService videoCallService)
        {
            _videoCallService = videoCallService;
        }

        [HttpPost("create-room")]
        [ProducesResponseType(typeof(ApiResponse<VideoCallRoomDto>), StatusCodes.Status201Created)]
        public async Task<IActionResult> CreateRoom([FromBody] CreateRoomDto dto)
        {
            try
            {
                var room = await _videoCallService.CreateRoomAsync(dto.RoomName, dto.MaxParticipants);
                return CreatedAtAction(nameof(GetRoomInfo), new { roomName = room.RoomName },
                    ApiResponse<VideoCallRoomDto>.SuccessResponse(room, "Room created successfully"));
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
            var userIdClaim = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
            if (!int.TryParse(userIdClaim, out var userId))
                return Unauthorized(ApiResponse<object>.ErrorResponse("Invalid user identity"));

            try
            {
                var token = await _videoCallService.GenerateTokenAsync(dto.RoomName, dto.ParticipantName, userId);
                return Ok(ApiResponse<VideoCallTokenDto>.SuccessResponse(token, "Room token generated successfully"));
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

        [HttpGet("rooms/{roomName}")]
        [ProducesResponseType(typeof(ApiResponse<VideoCallRoomDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> GetRoomInfo(string roomName)
        {
            var room = await _videoCallService.GetRoomInfoAsync(roomName);
            if (room == null)
                return NotFound(ApiResponse<object>.ErrorResponse("Room not found"));

            return Ok(ApiResponse<VideoCallRoomDto>.SuccessResponse(room));
        }

        [HttpGet("rooms/{roomName}/participants")]
        [ProducesResponseType(typeof(ApiResponse<List<ParticipantDto>>), StatusCodes.Status200OK)]
        public async Task<IActionResult> GetParticipants(string roomName)
        {
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
        [Authorize(Roles = "Admin")]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status200OK)]
        public async Task<IActionResult> EndRoom(string roomName)
        {
            var ended = await _videoCallService.EndRoomAsync(roomName);
            if (!ended)
                return NotFound(ApiResponse<object>.ErrorResponse("Room not found"));

            return Ok(ApiResponse<object>.SuccessResponse(null, "Room ended successfully"));
        }
    }
}
