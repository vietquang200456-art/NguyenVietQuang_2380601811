import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/device.dart';

class DeviceApi {
  final String? token;
  final String? userId;
  final String? userRole;
  final String? userName;

  const DeviceApi({this.token, this.userId, this.userRole, this.userName});

  Map<String, String> get headers {
    final result = <String, String>{'Content-Type': 'application/json'};
    if (token != null && token!.isNotEmpty) result['Authorization'] = 'Bearer $token';
    if (userId != null && userId!.isNotEmpty) result['X-User-Id'] = userId!;
    if (userRole != null && userRole!.isNotEmpty) result['X-User-Role'] = userRole!;
    if (userName != null && userName!.isNotEmpty) result['X-User-Name'] = Uri.encodeComponent(userName!);
    return result;
  }

  Future<dynamic> _request(String method, String path, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/devices$path');
    late http.Response response;
    if (method == 'GET') {
      response = await http.get(uri, headers: headers);
    } else if (method == 'POST') {
      response = await http.post(uri, headers: headers, body: jsonEncode(body ?? {}));
    } else if (method == 'PUT') {
      response = await http.put(uri, headers: headers, body: jsonEncode(body ?? {}));
    } else if (method == 'DELETE') {
      response = await http.delete(uri, headers: headers);
    } else {
      throw Exception('HTTP method không hỗ trợ');
    }

    Map<String, dynamic> data = {};
    try { data = jsonDecode(response.body) as Map<String, dynamic>; } catch (_) {}
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception((data['message'] ?? data['Message'] ?? data['error'] ?? 'API lỗi ${response.statusCode}').toString());
    }
    return data;
  }

  List<Device> _listFrom(dynamic value) {
    if (value is List) {
      return value.map((item) => Device.fromJson(Map<String, dynamic>.from(item))).toList();
    }
    return [];
  }

  Future<List<Device>> getDevices({String? search, String? category}) async {
    final query = <String, String>{'pageNumber': '1', 'pageSize': '100'};
    if (search != null && search.trim().isNotEmpty) query['search'] = search.trim();
    if (category != null && category.trim().isNotEmpty) query['category'] = category.trim();
    final result = await _request('GET', '?${Uri(queryParameters: query).query}');
    final data = result['data'] ?? result['Data'] ?? {};
    final items = data is Map ? (data['items'] ?? data['Items'] ?? data['data'] ?? data['Data'] ?? []) : data;
    return _listFrom(items);
  }

  Future<Device> createDevice(Map<String, dynamic> body) async {
    final result = await _request('POST', '', body: body);
    return Device.fromJson(Map<String, dynamic>.from(result['data'] ?? result['Data'] ?? {}));
  }

  Future<Device> updateDevice(int id, Map<String, dynamic> body) async {
    final result = await _request('PUT', '/$id', body: body);
    return Device.fromJson(Map<String, dynamic>.from(result['data'] ?? result['Data'] ?? {}));
  }

  Future<void> deleteDevice(int id) async {
    await _request('DELETE', '/$id');
  }
}
