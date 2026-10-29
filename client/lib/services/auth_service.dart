import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/auth_response.dart';

class AuthService {
  Future<Map<String, dynamic>> _post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    Map<String, dynamic> responseData = {};

    try {
      responseData = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {}

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = responseData['message'] ??
          responseData['Message'] ??
          responseData['error'] ??
          'Có lỗi xảy ra, vui lòng thử lại';

      throw Exception(message.toString());
    }

    return responseData;
  }

  Future<void> sendRegisterOtp({
    required String email,
  }) async {
    await _post(
      'send-otp',
      {
        'email': email,
      },
    );
  }

  Future<void> sendLoginOtp({
    required String email,
    required String password,
  }) async {
    await _post(
      'send-login-otp',
      {
        'email': email,
        'password': password,
      },
    );
  }

  Future<bool> verifyOtp({
    required String email,
    required String otp,
  }) async {
    await _post(
      'verify-otp',
      {
        'email': email,
        'otp': otp,
      },
    );

    return true;
  }

  Future<AuthResponse> register({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
    String? otp,
  }) async {
    final response = await _post(
      'register',
      {
        'email': email,
        'password': password,
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        if (otp != null && otp.isNotEmpty) 'otp': otp,
      },
    );

    return AuthResponse.fromJson(response);
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
    String? otp,
  }) async {
    final response = await _post(
      'login',
      {
        'email': email,
        'password': password,
        if (otp != null && otp.isNotEmpty) 'otp': otp,
      },
    );

    return AuthResponse.fromJson(response);
  }
}