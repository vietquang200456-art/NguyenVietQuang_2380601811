using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Server.DTOs;
using Server.Helpers;
using Server.Services;

namespace Server.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;
        private readonly JwtHelper _jwtHelper;

        public AuthController(IAuthService authService, JwtHelper jwtHelper)
        {
            _authService = authService;
            _jwtHelper = jwtHelper;
        }

        /// <summary>
        /// Đăng ký tài khoản mới qua Email
        /// </summary>
        [HttpPost("register")]
        [ProducesResponseType(typeof(ApiResponse<AuthResponseDto>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> Register([FromBody] RegisterDto registerDto)
        {
            try
            {
                var result = await _authService.RegisterAsync(registerDto);
                return Ok(ApiResponse<AuthResponseDto>.SuccessResponse(result, "Đăng ký thành công"));
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(ApiResponse<object>.ErrorResponse(ex.Message));
            }
        }

        /// <summary>
        /// Đăng nhập tài khoản qua Email và Mật khẩu
        /// </summary>
        [HttpPost("login")]
        [ProducesResponseType(typeof(ApiResponse<AuthResponseDto>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status401Unauthorized)]
        public async Task<IActionResult> Login([FromBody] LoginDto loginDto)
        {
            try
            {
                var result = await _authService.LoginAsync(loginDto);
                return Ok(ApiResponse<AuthResponseDto>.SuccessResponse(result, "Đăng nhập thành công"));
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(ApiResponse<object>.ErrorResponse(ex.Message));
            }
        }

        /// <summary>
        /// Gửi mã xác thực OTP qua Email
        /// </summary>
        [HttpPost("send-otp")]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> SendOtp([FromBody] SendOtpDto sendOtpDto)
        {
            try
            {
                var sent = await _authService.SendOtpAsync(sendOtpDto.Email);
                if (sent)
                {
                    return Ok(ApiResponse<object>.SuccessResponse(new { email = sendOtpDto.Email }, "Mã OTP đã được gửi đến email của bạn"));
                }
                return BadRequest(ApiResponse<object>.ErrorResponse("Không thể gửi email OTP, vui lòng kiểm tra lại địa chỉ email"));
            }
            catch (Exception ex)
            {
                return BadRequest(ApiResponse<object>.ErrorResponse(ex.Message));
            }
        }

        /// <summary>
        /// Xác thực mã OTP
        /// </summary>
        [HttpPost("verify-otp")]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> VerifyOtp([FromBody] VerifyOtpDto verifyOtpDto)
        {
            var isValid = await _authService.VerifyOtpAsync(verifyOtpDto.Email, verifyOtpDto.Otp);
            if (isValid)
            {
                return Ok(ApiResponse<object>.SuccessResponse(new { valid = true }, "Mã OTP hợp lệ"));
            }

            return BadRequest(ApiResponse<object>.ErrorResponse("Mã OTP không chính xác hoặc đã hết hạn"));
        }

        /// <summary>
        /// Lấy thông tin tài khoản hiện tại
        /// </summary>
        [HttpGet("me")]
        [Authorize]
        [ProducesResponseType(typeof(ApiResponse<UserDto>), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<IActionResult> GetCurrentUser()
        {
            var userId = _jwtHelper.GetUserIdFromToken(User);
            if (userId == null)
            {
                return Unauthorized(ApiResponse<object>.ErrorResponse("Token không hợp lệ"));
            }

            var user = await _authService.GetUserByIdAsync(userId.Value);
            if (user == null)
            {
                return NotFound(ApiResponse<object>.ErrorResponse("Người dùng không tồn tại"));
            }

            return Ok(ApiResponse<UserDto>.SuccessResponse(user));
        }
    }
}
