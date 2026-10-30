import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'storage_service.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  const ApiException(this.statusCode, this.message);
  @override
  String toString() => message;
}

class ApiClient {
  final StorageService storageService;
  ApiClient({StorageService? storageService}) : storageService = storageService ?? StorageService();

  Future<Map<String, String>> _headers({bool includeAuth = false}) async {
    final headers = <String, String>{'Content-Type': 'application/json', 'Accept': 'application/json'};
    if (includeAuth) {
      final token = await storageService.getToken();
      if (token != null && token.isNotEmpty) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Uri _uri(String path) {
    final normalized = path.startsWith('/') ? path : '/$path';
    return Uri.parse('${AppConfig.baseUrl}$normalized');
  }

  Future<dynamic> get(String path, {bool auth = false}) async {
    try {
      final response = await http.get(_uri(path), headers: await _headers(includeAuth: auth)).timeout(AppConfig.requestTimeout);
      return _handleResponse(response);
    } on TimeoutException {
      throw const ApiException(408, 'Kết nối tới máy chủ quá thời gian.');
    } on http.ClientException {
      throw const ApiException(0, 'Không thể kết nối tới máy chủ. Kiểm tra API URL và mạng.');
    }
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body, bool auth = false}) async {
    try {
      final response = await http.post(_uri(path), headers: await _headers(includeAuth: auth), body: jsonEncode(body ?? {})).timeout(AppConfig.requestTimeout);
      return _handleResponse(response);
    } on TimeoutException {
      throw const ApiException(408, 'Kết nối tới máy chủ quá thời gian.');
    } on http.ClientException {
      throw const ApiException(0, 'Không thể kết nối tới máy chủ. Kiểm tra API URL và mạng.');
    }
  }

  Future<dynamic> put(String path, {Map<String, dynamic>? body, bool auth = false}) async {
    try {
      final response = await http.put(_uri(path), headers: await _headers(includeAuth: auth), body: jsonEncode(body ?? {})).timeout(AppConfig.requestTimeout);
      return _handleResponse(response);
    } on TimeoutException {
      throw const ApiException(408, 'Kết nối tới máy chủ quá thời gian.');
    } on http.ClientException {
      throw const ApiException(0, 'Không thể kết nối tới máy chủ. Kiểm tra API URL và mạng.');
    }
  }



  Future<dynamic> delete(String path, {bool auth = false}) async {
    final response = await http.delete(_uri(path), headers: await _headers(includeAuth: auth)).timeout(AppConfig.requestTimeout);
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    dynamic decoded;
    try { decoded = response.body.isEmpty ? null : jsonDecode(utf8.decode(response.bodyBytes)); } catch (_) {}
    if (response.statusCode >= 200 && response.statusCode < 300) return decoded ?? <String, dynamic>{};
    var message = 'Máy chủ trả về lỗi (${response.statusCode}).';
    if (decoded is Map<String, dynamic>) {
      message = (decoded['message'] ?? decoded['title'] ?? message).toString();
      final errors = decoded['errors'];
      if (errors is Map) message = errors.values.expand((v) => v is List ? v : [v]).join('\n');
    }
    if (response.statusCode == 401) message = 'Phiên đăng nhập đã hết hạn hoặc thông tin không chính xác.';
    if (response.statusCode == 403) message = 'Bạn không có quyền thực hiện thao tác này.';
    throw ApiException(response.statusCode, message);
  }
}

