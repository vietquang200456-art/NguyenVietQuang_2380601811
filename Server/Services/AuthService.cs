using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;
using Server.Data;
using Server.DTOs;
using Server.Helpers;
using Server.Models;

namespace Server.Services
{
    public interface IAuthService
    {
        Task<AuthResponseDto> RegisterAsync(RegisterDto registerDto);
        Task<AuthResponseDto> LoginAsync(LoginDto loginDto);
        Task<bool> SendOtpAsync(string email);
        Task<bool> VerifyOtpAsync(string email, string otp);
        Task<UserDto?> GetUserByIdAsync(int userId);
    }

    public class AuthService : IAuthService
    {
        private readonly ApplicationDbContext _context;
        private readonly JwtHelper _jwtHelper;
        private readonly IEmailService _emailService;
        private readonly IMemoryCache _memoryCache;
        private readonly ILogger<AuthService> _logger;

        public AuthService(
            ApplicationDbContext context,
            JwtHelper jwtHelper,
            IEmailService emailService,
            IMemoryCache memoryCache,
            ILogger<AuthService> logger)
        {
            _context = context;
            _jwtHelper = jwtHelper;
            _emailService = emailService;
            _memoryCache = memoryCache;
            _logger = logger;
        }

        public async Task<AuthResponseDto> RegisterAsync(RegisterDto registerDto)
        {
            var normalizedEmail = registerDto.Email.Trim().ToLower();

            // Check if email already exists
            if (await _context.Users.AnyAsync(u => u.Email.ToLower() == normalizedEmail))
            {
                throw new InvalidOperationException("Email đã được sử dụng");
            }

            // Verify OTP if provided
            if (!string.IsNullOrWhiteSpace(registerDto.Otp))
            {
                var cacheKey = $"otp_{normalizedEmail}";
                if (!_memoryCache.TryGetValue(cacheKey, out string? storedOtp) || storedOtp != registerDto.Otp.Trim())
                {
                    throw new InvalidOperationException("Mã OTP không chính xác hoặc đã hết hạn");
                }
                _memoryCache.Remove(cacheKey);
            }

            // Create new user
            var user = new User
            {
                Email = normalizedEmail,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(registerDto.Password),
                FullName = registerDto.FullName.Trim(),
                PhoneNumber = string.IsNullOrWhiteSpace(registerDto.PhoneNumber) ? null : registerDto.PhoneNumber.Trim(),
                Role = UserRole.User,
                CreatedAt = DateTime.UtcNow,
                IsActive = true
            };

            _context.Users.Add(user);
            await _context.SaveChangesAsync();

            // Send welcome email via Resend
            try
            {
                await _emailService.SendWelcomeEmailAsync(user.Email, user.FullName);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Lỗi khi gửi email chào mừng tới {Email}", user.Email);
            }

            // Generate token
            var token = _jwtHelper.GenerateToken(user);

            return new AuthResponseDto
            {
                Token = token,
                User = MapToUserDto(user)
            };
        }

        public async Task<AuthResponseDto> LoginAsync(LoginDto loginDto)
        {
            var normalizedEmail = loginDto.Email.Trim().ToLower();

            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.Email.ToLower() == normalizedEmail);

            if (user == null || !BCrypt.Net.BCrypt.Verify(loginDto.Password, user.PasswordHash))
            {
                throw new UnauthorizedAccessException("Email hoặc mật khẩu không chính xác");
            }

            if (!user.IsActive)
            {
                throw new UnauthorizedAccessException("Tài khoản đã bị vô hiệu hóa");
            }

            // Generate token
            var token = _jwtHelper.GenerateToken(user);

            return new AuthResponseDto
            {
                Token = token,
                User = MapToUserDto(user)
            };
        }

        public async Task<bool> SendOtpAsync(string email)
        {
            var normalizedEmail = email.Trim().ToLower();
            var otp = Random.Shared.Next(100000, 999999).ToString();
            var cacheKey = $"otp_{normalizedEmail}";

            _memoryCache.Set(cacheKey, otp, TimeSpan.FromMinutes(5));

            return await _emailService.SendOtpEmailAsync(normalizedEmail, otp);
        }

        public Task<bool> VerifyOtpAsync(string email, string otp)
        {
            var normalizedEmail = email.Trim().ToLower();
            var cacheKey = $"otp_{normalizedEmail}";

            if (_memoryCache.TryGetValue(cacheKey, out string? storedOtp) && storedOtp == otp.Trim())
            {
                return Task.FromResult(true);
            }

            return Task.FromResult(false);
        }

        public async Task<UserDto?> GetUserByIdAsync(int userId)
        {
            var user = await _context.Users.FindAsync(userId);
            return user != null ? MapToUserDto(user) : null;
        }

        private static UserDto MapToUserDto(User user)
        {
            return new UserDto
            {
                Id = user.Id,
                Email = user.Email,
                FullName = user.FullName,
                PhoneNumber = user.PhoneNumber,
                Role = user.Role.ToString(),
                CreatedAt = user.CreatedAt
            };
        }
    }
}
