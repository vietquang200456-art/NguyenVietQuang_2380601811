using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using System.Text.Json;
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
        private readonly Dictionary<string, VideoCallRoomDto> _rooms = new(StringComparer.OrdinalIgnoreCase);
        private readonly object _lock = new();

        public LiveKitService(IConfiguration configuration, ILogger<LiveKitService> logger)
        {
            _apiKey = configuration["LiveKit:ApiKey"] ?? "";
            _apiSecret = configuration["LiveKit:ApiSecret"] ?? "";
            _wsUrl = configuration["LiveKit:WsUrl"] ?? "";
            _logger = logger;

            SeedDefaultRooms();
        }

        private void SeedDefaultRooms()
        {
            lock (_lock)
            {
                _rooms["phong-ho-tro-ky-thuat"] = new VideoCallRoomDto
                {
                    RoomName = "phong-ho-tro-ky-thuat",
                    MaxParticipants = 10,
                    CurrentParticipants = 0,
                    CreatedAt = DateTime.UtcNow,
                    IsActive = true,
                    CreatedByUserId = 0,
                    CreatedByName = "Tổng Đài Kỹ Thuật (STAFF)",
                    CreatedByRole = "Staff",
                    CallType = "support",
                    Description = "Phòng trực tuyến hỗ trợ cài đặt & kiểm tra thiết bị trẻ em (User <-> Staff)"
                };

                _rooms["ho-tro-khan-cap-sos"] = new VideoCallRoomDto
                {
                    RoomName = "ho-tro-khan-cap-sos",
                    MaxParticipants = 5,
                    CurrentParticipants = 0,
                    CreatedAt = DateTime.UtcNow,
                    IsActive = true,
                    CreatedByUserId = 0,
                    CreatedByName = "Trạm Trực SOS 24/7 (STAFF)",
                    CreatedByRole = "Staff",
                    CallType = "one_to_one",
                    Description = "Kênh kết nối khẩn cấp 1-1 giữa Phụ huynh (User) và Nhân viên trực ca (Staff)"
                };
            }
        }

        public Task<List<VideoCallRoomDto>> GetActiveRoomsAsync()
        {
            lock (_lock)
            {
                var activeRooms = _rooms.Values
                    .Where(r => r.IsActive)
                    .OrderByDescending(r => r.CurrentParticipants)
                    .ThenByDescending(r => r.CreatedAt)
                    .Select(CloneRoom)
                    .ToList();

                return Task.FromResult(activeRooms);
            }
        }

        public Task<VideoCallRoomDto> CreateRoomAsync(
            string roomName,
            int maxParticipants = 10,
            string callType = "support",
            string? description = null,
            int createdByUserId = 0,
            string createdByName = "",
            string createdByRole = "User")
        {
            if (string.IsNullOrWhiteSpace(roomName))
                throw new ArgumentException("Tên phòng gọi là bắt buộc");

            var normalizedRoomName = roomName.Trim();

            if (maxParticipants < 2 || maxParticipants > 100)
                throw new ArgumentException("Số người tham gia tối đa phải từ 2 đến 100");

            lock (_lock)
            {
                if (_rooms.TryGetValue(normalizedRoomName, out var existingRoom))
                {
                    existingRoom.IsActive = true;
                    existingRoom.MaxParticipants = maxParticipants;
                    if (!string.IsNullOrWhiteSpace(callType))
                        existingRoom.CallType = callType;
                    if (!string.IsNullOrWhiteSpace(description))
                        existingRoom.Description = description;
                    if (string.IsNullOrWhiteSpace(existingRoom.CreatedByName) && !string.IsNullOrWhiteSpace(createdByName))
                        existingRoom.CreatedByName = createdByName;
                    if (string.IsNullOrWhiteSpace(existingRoom.CreatedByRole) && !string.IsNullOrWhiteSpace(createdByRole))
                        existingRoom.CreatedByRole = createdByRole;

                    return Task.FromResult(CloneRoom(existingRoom));
                }

                var room = new VideoCallRoomDto
                {
                    RoomName = normalizedRoomName,
                    MaxParticipants = maxParticipants,
                    CurrentParticipants = 0,
                    CreatedAt = DateTime.UtcNow,
                    IsActive = true,
                    CreatedByUserId = createdByUserId,
                    CreatedByName = string.IsNullOrWhiteSpace(createdByName) ? $"User #{createdByUserId}" : createdByName,
                    CreatedByRole = string.IsNullOrWhiteSpace(createdByRole) ? "User" : createdByRole,
                    CallType = string.IsNullOrWhiteSpace(callType) ? "support" : callType,
                    Description = string.IsNullOrWhiteSpace(description)
                        ? $"Phòng gọi điện giữa User và Staff ({normalizedRoomName})"
                        : description.Trim()
                };

                _rooms[normalizedRoomName] = room;
                return Task.FromResult(CloneRoom(room));
            }
        }

        public Task<VideoCallTokenDto> GenerateTokenAsync(
            string roomName,
            string participantName,
            int userId,
            string userRole = "User",
            bool isAudioOnly = false)
        {
            if (string.IsNullOrWhiteSpace(roomName))
                throw new ArgumentException("Tên phòng gọi là bắt buộc");

            if (string.IsNullOrWhiteSpace(participantName))
                throw new ArgumentException("Tên người tham gia là bắt buộc");

            if (string.IsNullOrWhiteSpace(_apiKey) || string.IsNullOrWhiteSpace(_apiSecret) ||
                _apiKey.StartsWith("YOUR_", StringComparison.OrdinalIgnoreCase))
            {
                throw new InvalidOperationException("LiveKit chưa được cấu hình. Vui lòng thiết lập LiveKit:ApiKey và LiveKit:ApiSecret.");
            }

            var normalizedRoomName = roomName.Trim();
            var cleanParticipantName = participantName.Trim();
            var cleanRole = string.IsNullOrWhiteSpace(userRole) ? "User" : userRole.Trim();
            var participantIdentity = $"user-{userId}-{cleanRole.ToLowerInvariant()}";

            string roomCallType = "support";

            lock (_lock)
            {
                if (!_rooms.TryGetValue(normalizedRoomName, out var room) || !room.IsActive)
                {
                    room = new VideoCallRoomDto
                    {
                        RoomName = normalizedRoomName,
                        MaxParticipants = 10,
                        CurrentParticipants = 0,
                        CreatedAt = DateTime.UtcNow,
                        IsActive = true,
                        CreatedByUserId = userId,
                        CreatedByName = cleanParticipantName,
                        CreatedByRole = cleanRole,
                        CallType = normalizedRoomName.StartsWith("group", StringComparison.OrdinalIgnoreCase)
                            ? "group"
                            : "support",
                        Description = $"Phòng gọi điện trực tiếp ({normalizedRoomName})"
                    };
                    _rooms[normalizedRoomName] = room;
                }

                var existingParticipant = room.Participants
                    .FirstOrDefault(p => string.Equals(p.Identity, participantIdentity, StringComparison.OrdinalIgnoreCase));

                if (existingParticipant == null)
                {
                    if (room.Participants.Count(p => p.IsConnected) >= room.MaxParticipants)
                        throw new InvalidOperationException("Phòng gọi đã đầy");

                    room.Participants.Add(new ParticipantDto
                    {
                        Identity = participantIdentity,
                        Name = cleanParticipantName,
                        Role = cleanRole,
                        JoinedAt = DateTime.UtcNow,
                        IsConnected = true
                    });
                }
                else
                {
                    existingParticipant.Name = cleanParticipantName;
                    existingParticipant.Role = cleanRole;
                    existingParticipant.IsConnected = true;
                    existingParticipant.JoinedAt = DateTime.UtcNow;
                }

                room.CurrentParticipants = room.Participants.Count(p => p.IsConnected);
                roomCallType = room.CallType;
            }

            var now = DateTime.UtcNow;
            var expiresAt = now.AddHours(4);
            var nowUnix = new DateTimeOffset(now).ToUnixTimeSeconds();
            var expUnix = new DateTimeOffset(expiresAt).ToUnixTimeSeconds();

            var grants = new Dictionary<string, object>
            {
                ["roomCreate"] = true,
                ["roomJoin"] = true,
                ["room"] = normalizedRoomName,
                ["canPublish"] = true,
                ["canSubscribe"] = true,
                ["canPublishData"] = true
            };

            var metadataJson = JsonSerializer.Serialize(new
            {
                userId,
                role = cleanRole,
                name = cleanParticipantName,
                isAudioOnly
            });

            var claims = new[]
            {
                new Claim(JwtRegisteredClaimNames.Iss, _apiKey),
                new Claim(JwtRegisteredClaimNames.Sub, participantIdentity),
                new Claim(JwtRegisteredClaimNames.Jti, $"{participantIdentity}-{nowUnix}"),
                new Claim(JwtRegisteredClaimNames.Name, cleanParticipantName),
                new Claim("metadata", metadataJson),
                new Claim(JwtRegisteredClaimNames.Nbf, nowUnix.ToString(), ClaimValueTypes.Integer64),
                new Claim(JwtRegisteredClaimNames.Iat, nowUnix.ToString(), ClaimValueTypes.Integer64),
                new Claim(JwtRegisteredClaimNames.Exp, expUnix.ToString(), ClaimValueTypes.Integer64),
                new Claim("video", JsonSerializer.Serialize(grants), JsonClaimValueTypes.Json)
            };

            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_apiSecret));
            var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
            var token = new JwtSecurityToken(claims: claims, signingCredentials: credentials);

            _logger.LogInformation("Đã cấp LiveKit token cho {Participant} ({Role}) vào phòng {RoomName}",
                cleanParticipantName, cleanRole, normalizedRoomName);

            return Task.FromResult(new VideoCallTokenDto
            {
                Token = new JwtSecurityTokenHandler().WriteToken(token),
                WsUrl = _wsUrl,
                RoomName = normalizedRoomName,
                ParticipantName = cleanParticipantName,
                ParticipantRole = cleanRole,
                CallType = roomCallType,
                IsAudioOnly = isAudioOnly,
                ExpiresAt = expiresAt
            });
        }

        public Task<VideoCallRoomDto?> GetRoomInfoAsync(string roomName)
        {
            if (string.IsNullOrWhiteSpace(roomName))
                return Task.FromResult<VideoCallRoomDto?>(null);

            lock (_lock)
            {
                if (_rooms.TryGetValue(roomName.Trim(), out var room))
                {
                    return Task.FromResult<VideoCallRoomDto?>(CloneRoom(room));
                }
                return Task.FromResult<VideoCallRoomDto?>(null);
            }
        }

        public Task<List<ParticipantDto>> GetParticipantsAsync(string roomName)
        {
            if (string.IsNullOrWhiteSpace(roomName))
                throw new KeyNotFoundException("Không tìm thấy phòng gọi");

            lock (_lock)
            {
                if (!_rooms.TryGetValue(roomName.Trim(), out var room))
                    throw new KeyNotFoundException("Không tìm thấy phòng gọi");

                var list = room.Participants
                    .Where(p => p.IsConnected)
                    .OrderBy(p => p.JoinedAt)
                    .ToList();

                return Task.FromResult(list);
            }
        }

        public Task<bool> LeaveRoomAsync(string roomName, int userId, string? userRole = null)
        {
            if (string.IsNullOrWhiteSpace(roomName))
                return Task.FromResult(false);

            lock (_lock)
            {
                if (!_rooms.TryGetValue(roomName.Trim(), out var room))
                    return Task.FromResult(false);

                var prefix = $"user-{userId}-";
                foreach (var p in room.Participants)
                {
                    if (!string.IsNullOrWhiteSpace(userRole))
                    {
                        var exactId = $"user-{userId}-{userRole.Trim().ToLowerInvariant()}";
                        if (string.Equals(p.Identity, exactId, StringComparison.OrdinalIgnoreCase))
                        {
                            p.IsConnected = false;
                        }
                    }
                    else if (p.Identity.StartsWith(prefix, StringComparison.OrdinalIgnoreCase))
                    {
                        p.IsConnected = false;
                    }
                }

                room.CurrentParticipants = room.Participants.Count(p => p.IsConnected);
                return Task.FromResult(true);
            }
        }

        public Task<bool> EndRoomAsync(string roomName)
        {
            if (string.IsNullOrWhiteSpace(roomName))
                return Task.FromResult(false);

            var normalized = roomName.Trim();

            lock (_lock)
            {
                if (!_rooms.TryGetValue(normalized, out var room))
                    return Task.FromResult(false);

                room.Participants.Clear();
                room.CurrentParticipants = 0;

                // Giữ 2 phòng mặc định luôn sẵn sàng cho User và Staff
                if (string.Equals(normalized, "phong-ho-tro-ky-thuat", StringComparison.OrdinalIgnoreCase) ||
                    string.Equals(normalized, "ho-tro-khan-cap-sos", StringComparison.OrdinalIgnoreCase))
                {
                    room.IsActive = true;
                }
                else
                {
                    room.IsActive = false;
                }

                return Task.FromResult(true);
            }
        }

        private static VideoCallRoomDto CloneRoom(VideoCallRoomDto room)
        {
            var connectedParticipants = room.Participants
                .Where(p => p.IsConnected)
                .Select(p => new ParticipantDto
                {
                    Identity = p.Identity,
                    Name = p.Name,
                    Role = p.Role,
                    JoinedAt = p.JoinedAt,
                    IsConnected = p.IsConnected
                })
                .ToList();

            return new VideoCallRoomDto
            {
                RoomName = room.RoomName,
                MaxParticipants = room.MaxParticipants,
                CurrentParticipants = connectedParticipants.Count,
                CreatedAt = room.CreatedAt,
                IsActive = room.IsActive,
                CreatedByUserId = room.CreatedByUserId,
                CreatedByName = room.CreatedByName,
                CreatedByRole = room.CreatedByRole,
                CallType = room.CallType,
                Description = room.Description,
                Participants = connectedParticipants
            };
        }
    }
}
