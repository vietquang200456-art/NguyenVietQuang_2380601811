using Server.DTOs;

namespace Server.Services
{
    public interface IVideoCallService
    {
        Task<List<VideoCallRoomDto>> GetActiveRoomsAsync();
        Task<VideoCallRoomDto> CreateRoomAsync(
            string roomName,
            int maxParticipants = 10,
            string callType = "support",
            string? description = null,
            int createdByUserId = 0,
            string createdByName = "",
            string createdByRole = "User");
        Task<VideoCallTokenDto> GenerateTokenAsync(
            string roomName,
            string participantName,
            int userId,
            string userRole = "User",
            bool isAudioOnly = false);
        Task<VideoCallRoomDto?> GetRoomInfoAsync(string roomName);
        Task<List<ParticipantDto>> GetParticipantsAsync(string roomName);
        Task<bool> LeaveRoomAsync(string roomName, int userId, string? userRole = null);
        Task<bool> EndRoomAsync(string roomName);
    }
}
