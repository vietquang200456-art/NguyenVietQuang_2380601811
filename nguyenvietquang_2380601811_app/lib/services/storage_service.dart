import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String tokenKey = 'access_token';
  static const String userIdKey = 'user_id';
  static const String usernameKey = 'username';
  static const String roleKey = 'role';

  Future<void> saveAuth({required String token, required int userId, required String username, required String role}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
    await prefs.setInt(userIdKey, userId);
    await prefs.setString(usernameKey, username);
    await prefs.setString(roleKey, role);
  }

  Future<String?> getToken() async => (await SharedPreferences.getInstance()).getString(tokenKey);
  Future<String?> getRole() async => (await SharedPreferences.getInstance()).getString(roleKey);
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
  Future<void> clear() async => (await SharedPreferences.getInstance()).clear();
}
