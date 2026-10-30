import '../models/user.dart';
import 'api_client.dart';
import 'storage_service.dart';

class AuthService {
  final ApiClient apiClient;
  final StorageService storageService;

  AuthService({ApiClient? apiClient, StorageService? storageService})
      : apiClient = apiClient ?? ApiClient(),
        storageService = storageService ?? StorageService();

  Future<User> login({required String email, required String password}) async {
    final response = await apiClient.post(
      '/Auth/login',
      body: <String, dynamic>{
        'email': email.trim(),
        'password': password,
      },
    );
    return _saveAuth(response);
  }

  Future<User> loginWithGoogle({
    String? idToken,
    String? accessToken,
    required String email,
    String? displayName,
  }) async {
    if (idToken == null || idToken.isEmpty) {
      throw const ApiException(400, 'Không lấy được Google ID token.');
    }

    final response = await apiClient.post(
      '/Auth/google',
      body: <String, dynamic>{
        'idToken': idToken,
        'email': email.trim(),
        'displayName': displayName?.trim(),
      },
    );
    return _saveAuth(response);
  }

  Future<User> register({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
    required String otp,
  }) async {
    final response = await apiClient.post(
      '/Auth/register',
      body: <String, dynamic>{
        'email': email.trim(),
        'password': password,
        'fullName': fullName.trim(),
        'phoneNumber': phoneNumber?.trim().isEmpty == true ? null : phoneNumber?.trim(),
        'otp': otp.trim(),
      },
    );
    return _saveAuth(response);
  }

  Future<void> sendOtp({required String email}) async {
    await apiClient.post('/Auth/send-otp', body: <String, dynamic>{'email': email.trim()});
  }

  Future<void> verifyOtp({required String email, required String otp}) async {
    await apiClient.post('/Auth/verify-otp', body: <String, dynamic>{'email': email.trim(), 'otp': otp.trim()});
  }

  Future<User> _saveAuth(dynamic response) async {
    if (response is! Map || response['data'] is! Map) {
      throw const ApiException(500, 'Dữ liệu xác thực từ máy chủ không hợp lệ.');
    }

    final data = Map<String, dynamic>.from(response['data'] as Map);
    final token = data['token']?.toString();
    final userJson = data['user'];
    if (token == null || token.isEmpty || userJson is! Map) {
      throw const ApiException(500, 'Máy chủ không trả về token hoặc thông tin người dùng.');
    }

    final user = User.fromJson(Map<String, dynamic>.from(userJson));
    await storageService.saveAuth(
      token: token,
      userId: user.id,
      username: user.email,
      role: user.role,
    );
    return user;
  }

  Future<User> getCurrentUser() async {
    final response = await apiClient.get('/Auth/me', auth: true);
    if (response is! Map || response['data'] is! Map) {
      throw const ApiException(500, 'Thông tin phiên đăng nhập không hợp lệ.');
    }
    return User.fromJson(Map<String, dynamic>.from(response['data'] as Map));
  }

  Future<User> updateProfile({required String fullName, required String email, required String phoneNumber}) async {
    final response = await apiClient.put('/Auth/profile', auth: true, body: <String, dynamic>{
      'fullName': fullName.trim(),
      'email': email.trim(),
      'phoneNumber': phoneNumber.trim().isEmpty ? null : phoneNumber.trim(),
    });
    if (response is Map && response['data'] is Map) return User.fromJson(Map<String, dynamic>.from(response['data'] as Map));
    if (response is Map) return User.fromJson(Map<String, dynamic>.from(response));
    throw const ApiException(500, 'Dữ liệu hồ sơ từ máy chủ không hợp lệ.');
  }

  Future<void> logout() async {
    await storageService.clear();
  }
}
