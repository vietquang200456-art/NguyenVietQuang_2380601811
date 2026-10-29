using System.Net.Http.Json;
using Server.DTOs;

namespace Server.Services
{
    public class ResendEmailService : IEmailService
    {
        private readonly string _apiKey;
        private readonly string _fromEmail;
        private readonly string _fromName;
        private readonly string _baseUrl;
        private readonly HttpClient _httpClient;
        private readonly ILogger<ResendEmailService> _logger;

        public ResendEmailService(
            IConfiguration configuration,
            HttpClient httpClient,
            ILogger<ResendEmailService> logger)
        {
            _apiKey = configuration["Resend:ApiKey"] ?? "";
            _fromEmail = configuration["Resend:FromEmail"] ?? "";
            _fromName = configuration["Resend:FromName"] ?? "";
            _baseUrl = configuration["Domain:BaseUrl"] ?? "";
            _httpClient = httpClient;
            _logger = logger;
        }

        public async Task<bool> SendWelcomeEmailAsync(string toEmail, string userName)
        {
            var subject = "Chào mừng đến với Child Devices Management!";
            var htmlBody = $@"
                <!DOCTYPE html>
                <html>
                <head>
                    <style>
                        body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
                        .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
                        .header {{ background-color: #4CAF50; color: white; padding: 20px; text-align: center; }}
                        .content {{ padding: 20px; background-color: #f9f9f9; }}
                        .button {{ display: inline-block; padding: 10px 20px; background-color: #4CAF50; color: white; text-decoration: none; border-radius: 5px; }}
                        .footer {{ padding: 20px; text-align: center; font-size: 12px; color: #666; }}
                    </style>
                </head>
                <body>
                    <div class='container'>
                        <div class='header'>
                            <h1>Child Devices Management</h1>
                        </div>
                        <div class='content'>
                            <h2>Xin chào {userName}!</h2>
                            <p>Cảm ơn bạn đã đăng ký tài khoản tại <strong>Child Devices Management</strong>.</p>
                            <p>Chúng tôi cung cấp các thiết bị an toàn và chất lượng cao cho trẻ em của bạn.</p>
                            <p>Bạn có thể bắt đầu mua sắm ngay bây giờ!</p>
                            <p style='text-align: center; margin: 30px 0;'>
                                <a href='{_baseUrl}' class='button'>Truy cập Website</a>
                            </p>
                            <p>Nếu bạn có bất kỳ câu hỏi nào, đừng ngần ngại liên hệ với chúng tôi.</p>
                        </div>
                        <div class='footer'>
                            <p>&copy; 2026 Child Devices Management. All rights reserved.</p>
                            <p>Email: support@zeion.online</p>
                        </div>
                    </div>
                </body>
                </html>
            ";

            return await SendEmailAsync(toEmail, subject, htmlBody);
        }

        public async Task<bool> SendOrderConfirmationAsync(string toEmail, OrderDto order)
        {
            var subject = $"Xác nhận đơn hàng #{order.OrderNumber}";
            var itemsList = string.Join("", order.Items.Select(item =>
                $"<tr><td>{item.DeviceName}</td><td style='text-align: center;'>{item.Quantity}</td><td style='text-align: right;'>{item.UnitPrice:N0} ₫</td><td style='text-align: right;'>{item.TotalPrice:N0} ₫</td></tr>"));

            var htmlBody = $@"
                <!DOCTYPE html>
                <html>
                <head>
                    <style>
                        body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
                        .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
                        .header {{ background-color: #2196F3; color: white; padding: 20px; text-align: center; }}
                        .content {{ padding: 20px; background-color: #f9f9f9; }}
                        table {{ width: 100%; border-collapse: collapse; margin: 20px 0; }}
                        th, td {{ padding: 10px; border-bottom: 1px solid #ddd; }}
                        th {{ background-color: #2196F3; color: white; text-align: left; }}
                        .total {{ font-size: 18px; font-weight: bold; color: #2196F3; }}
                        .info-box {{ background-color: white; padding: 15px; margin: 15px 0; border-left: 4px solid #2196F3; }}
                        .footer {{ padding: 20px; text-align: center; font-size: 12px; color: #666; }}
                    </style>
                </head>
                <body>
                    <div class='container'>
                        <div class='header'>
                            <h1>Xác Nhận Đơn Hàng</h1>
                            <p>#{order.OrderNumber}</p>
                        </div>
                        <div class='content'>
                            <p>Cảm ơn bạn đã đặt hàng tại Child Devices Management!</p>
                            <p>Đơn hàng của bạn đã được tiếp nhận và đang được xử lý.</p>
                            
                            <h3>Chi tiết đơn hàng:</h3>
                            <table>
                                <thead>
                                    <tr>
                                        <th>Sản phẩm</th>
                                        <th style='text-align: center;'>Số lượng</th>
                                        <th style='text-align: right;'>Đơn giá</th>
                                        <th style='text-align: right;'>Thành tiền</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    {itemsList}
                                </tbody>
                            </table>
                            
                            <p class='total'>Tổng tiền: {order.TotalAmount:N0} ₫</p>
                            
                            <div class='info-box'>
                                <h4>Thông tin giao hàng:</h4>
                                <p><strong>Địa chỉ:</strong> {order.ShippingAddress}</p>
                                <p><strong>Số điện thoại:</strong> {order.PhoneNumber}</p>
                                {(string.IsNullOrEmpty(order.Notes) ? "" : $"<p><strong>Ghi chú:</strong> {order.Notes}</p>")}
                            </div>
                            
                            <p>Chúng tôi sẽ liên hệ với bạn sớm nhất để xác nhận và giao hàng.</p>
                        </div>
                        <div class='footer'>
                            <p>&copy; 2026 Child Devices Management. All rights reserved.</p>
                        </div>
                    </div>
                </body>
                </html>
            ";

            return await SendEmailAsync(toEmail, subject, htmlBody);
        }

        public async Task<bool> SendShippingNotificationAsync(string toEmail, OrderDto order)
        {
            var subject = $"Đơn hàng #{order.OrderNumber} đang được giao";
            var htmlBody = $@"
                <!DOCTYPE html>
                <html>
                <head>
                    <style>
                        body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
                        .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
                        .header {{ background-color: #FF9800; color: white; padding: 20px; text-align: center; }}
                        .content {{ padding: 20px; background-color: #f9f9f9; }}
                        .status {{ background-color: #FF9800; color: white; padding: 10px 20px; border-radius: 5px; display: inline-block; }}
                        .footer {{ padding: 20px; text-align: center; font-size: 12px; color: #666; }}
                    </style>
                </head>
                <body>
                    <div class='container'>
                        <div class='header'>
                            <h1>Đơn Hàng Đang Được Giao</h1>
                        </div>
                        <div class='content'>
                            <p>Đơn hàng <strong>#{order.OrderNumber}</strong> của bạn đang trên đường giao đến!</p>
                            <p style='text-align: center; margin: 20px 0;'>
                                <span class='status'>Đang giao hàng</span>
                            </p>
                            <p><strong>Địa chỉ giao hàng:</strong> {order.ShippingAddress}</p>
                            <p><strong>Số điện thoại:</strong> {order.PhoneNumber}</p>
                            <p>Vui lòng chuẩn bị nhận hàng. Shipper sẽ liên hệ với bạn trước khi giao.</p>
                            <p>Cảm ơn bạn đã tin tưởng Child Devices Management!</p>
                        </div>
                        <div class='footer'>
                            <p>&copy; 2026 Child Devices Management. All rights reserved.</p>
                        </div>
                    </div>
                </body>
                </html>
            ";

            return await SendEmailAsync(toEmail, subject, htmlBody);
        }

        public async Task<bool> SendPasswordResetEmailAsync(string toEmail, string resetToken)
        {
            var subject = "Yêu cầu đặt lại mật khẩu";
            var resetLink = $"{_baseUrl}/reset-password?token={resetToken}";
            var htmlBody = $@"
                <!DOCTYPE html>
                <html>
                <head>
                    <style>
                        body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
                        .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
                        .header {{ background-color: #f44336; color: white; padding: 20px; text-align: center; }}
                        .content {{ padding: 20px; background-color: #f9f9f9; }}
                        .button {{ display: inline-block; padding: 12px 24px; background-color: #f44336; color: white; text-decoration: none; border-radius: 5px; }}
                        .warning {{ background-color: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; margin: 20px 0; }}
                        .footer {{ padding: 20px; text-align: center; font-size: 12px; color: #666; }}
                    </style>
                </head>
                <body>
                    <div class='container'>
                        <div class='header'>
                            <h1>Đặt Lại Mật Khẩu</h1>
                        </div>
                        <div class='content'>
                            <p>Chúng tôi nhận được yêu cầu đặt lại mật khẩu cho tài khoản của bạn.</p>
                            <p style='text-align: center; margin: 30px 0;'>
                                <a href='{resetLink}' class='button'>Đặt Lại Mật Khẩu</a>
                            </p>
                            <div class='warning'>
                                <p><strong>Lưu ý:</strong></p>
                                <ul>
                                    <li>Link này chỉ có hiệu lực trong 24 giờ</li>
                                    <li>Nếu bạn không yêu cầu đặt lại mật khẩu, vui lòng bỏ qua email này</li>
                                    <li>Không chia sẻ link này với bất kỳ ai</li>
                                </ul>
                            </div>
                        </div>
                        <div class='footer'>
                            <p>&copy; 2026 Child Devices Management. All rights reserved.</p>
                        </div>
                    </div>
                </body>
                </html>
            ";

            return await SendEmailAsync(toEmail, subject, htmlBody);
        }

        public async Task<bool> SendEmailAsync(string toEmail, string subject, string htmlBody)
        {
            try
            {
                var request = new HttpRequestMessage(HttpMethod.Post, "https://api.resend.com/emails");
                request.Headers.Add("Authorization", $"Bearer {_apiKey}");

                var payload = new
                {
                    from = $"{_fromName} <{_fromEmail}>",
                    to = new[] { toEmail },
                    subject = subject,
                    html = htmlBody
                };

                request.Content = JsonContent.Create(payload);

                var response = await _httpClient.SendAsync(request);
                
                if (response.IsSuccessStatusCode)
                {
                    _logger.LogInformation($"Email sent successfully to {toEmail}");
                    return true;
                }
                else
                {
                    var error = await response.Content.ReadAsStringAsync();
                    _logger.LogError($"Failed to send email to {toEmail}. Status: {response.StatusCode}, Error: {error}");
                    return false;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Exception while sending email to {toEmail}");
                return false;
            }
        }
    }
}
