using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.IdentityModel.Tokens;
using Server.DTOs;

namespace Server.Services
{
    public class LiveKitService : IVideoCallService
    {
        private readonly string _apiKey;
        private readonly string _apiSecret;
        private readonly string _wsUrl;
        private readonly ILogger<LiveKitService> _logger;
        private readonly Dictionary<string, VideoCallRoomDto> _rooms = new();
        private readonly object _lock = new();

        public LiveKitService(IConfiguration configuration, ILogger<LiveKitService> logger)
        {
            _apiKey = configuration["LiveKit:ApiKey"] ?? "";
            _apiSecret = configuration["LiveKit:ApiSecret"] ?? "";
            _wsUrl = configuration["LiveKit:WsUrl"] ?? "";
            _logger = logger;
        }

        public Task<VideoCallRoomDto> CreateRoomAsync(string roomName, int maxParticipants = 10)
        {
            if (string.IsNullOrWhiteSpace(roomName))
                throw new ArgumentException("Room name is required");

            if (maxParticipants < 2 || maxParticipants > 100)
                throw new ArgumentException("Max participants must be between 2 and 100");

            var room = new VideoCallRoomDto
            {
                RoomName = roomName,
                MaxParticipants = maxParticipants,
                CurrentParticipants = 0,
                CreatedAt = DateTime.UtcNow,
                IsActive = true
            };

            lock (_lock)
            {
                if (_rooms.ContainsKey(roomName) && _rooms[roomName].IsActive)
                    throw new InvalidOperationException("Room already exists");

                _rooms[roomName] = room;
            }

            return Task.FromResult(room);
        }

        public Task<VideoCallTokenDto> GenerateTokenAsync(string roomName, string participantName, int userId)
        {
            if (string.IsNullOrWhiteSpace(roomName))
                throw new ArgumentException("Room name is required");

            if (string.IsNullOrWhiteSpace(participantName))
                throw new ArgumentException("Participant name is required");

            if (string.IsNullOrWhiteSpace(_apiKey) || string.IsNullOrWhiteSpace(_apiSecret) ||
                _apiKey.StartsWith("YOUR_", StringComparison.OrdinalIgnoreCase))
            {
                throw new InvalidOperationException("LiveKit is not configured. Set LiveKit:ApiKey and LiveKit:ApiSecret in configuration.");
            }

            lock (_lock)
            {
                if (!_rooms.ContainsKey(roomName) || !_rooms[roomName].IsActive)
                    throw new KeyNotFoundException("Room not found or inactive");

                if (_rooms[roomName].CurrentParticipants >= _rooms[roomName].MaxParticipants)
                    throw new InvalidOperationException("Room is full");

                _rooms[roomName].CurrentParticipants++;
            }

            var now = DateTime.UtcNow;
            var expiresAt = now.AddHours(2);
            var grants = new
            {
                roomJoin = true,
                room = roomName,
                canPublish = true,
                canSubscribe = true,
                canPublishData = true
            };

            var claims = new[]
            {
                new Claim(JwtRegisteredClaimNames.Iss, _apiKey),
                new Claim(JwtRegisteredClaimNames.Sub, $"user-{userId}"),
                new Claim(JwtRegisteredClaimNames.Name, participantName),
                new Claim(JwtRegisteredClaimNames.Iat, new DateTimeOffset(now).ToUnixTimeSeconds().ToString(), ClaimValueTypes.Integer64),
                new Claim(JwtRegisteredClaimNames.Exp, new DateTimeOffset(expiresAt).ToUnixTimeSeconds().ToString(), ClaimValueTypes.Integer64),
                new Claim("video", System.Text.Json.JsonSerializer.Serialize(grants))
            };

            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_apiSecret));
            var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
            var token = new JwtSecurityToken(claims: claims, signingCredentials: credentials);

            return Task.FromResult(new VideoCallTokenDto
            {
                Token = new JwtSecurityTokenHandler().WriteToken(token),
                WsUrl = _wsUrl,
                RoomName = roomName,
                ExpiresAt = expiresAt
            });
        }

        public Task<VideoCallRoomDto?> GetRoomInfoAsync(string roomName)
        {
            lock (_lock)
            {
                _rooms.TryGetValue(roomName, out var room);
                return Task.FromResult(room);
            }
        }

        public Task<List<ParticipantDto>> GetParticipantsAsync(string roomName)
        {
            lock (_lock)
            {
                if (!_rooms.ContainsKey(roomName))
                    throw new KeyNotFoundException("Room not found");

                // Participant details are maintained by LiveKit Server in production.
                return Task.FromResult(new List<ParticipantDto>());
            }
        }

        public Task<bool> EndRoomAsync(string roomName)
        {
            lock (_lock)
            {
                if (!_rooms.TryGetValue(roomName, out var room))
                    return Task.FromResult(false);

                room.IsActive = false;
                room.CurrentParticipants = 0;
                return Task.FromResult(true);
            }
        }
    }
}
