namespace Server.DTOs
{
    public class CreateRoomDto
    {
        public string RoomName { get; set; } = string.Empty;
        public int MaxParticipants { get; set; } = 10;
    }

    public class JoinRoomDto
    {
        public string RoomName { get; set; } = string.Empty;
        public string ParticipantName { get; set; } = string.Empty;
    }

    public class VideoCallRoomDto
    {
        public string RoomName { get; set; } = string.Empty;
        public int MaxParticipants { get; set; }
        public int CurrentParticipants { get; set; }
        public DateTime CreatedAt { get; set; }
        public bool IsActive { get; set; }
    }

    public class VideoCallTokenDto
    {
        public string Token { get; set; } = string.Empty;
        public string WsUrl { get; set; } = string.Empty;
        public string RoomName { get; set; } = string.Empty;
        public DateTime ExpiresAt { get; set; }
    }

    public class ParticipantDto
    {
        public string Identity { get; set; } = string.Empty;
        public string Name { get; set; } = string.Empty;
        public DateTime JoinedAt { get; set; }
        public bool IsConnected { get; set; }
    }
}
