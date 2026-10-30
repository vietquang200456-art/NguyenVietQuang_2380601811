import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/participant.dart';
import '../models/video_call_room.dart';
import '../models/video_call_token.dart';

class VideoCallApi {
  final String? jwtToken;
  final String? userId;
  final String? userRole;
  final String? userName;

  const VideoCallApi({
    this.jwtToken,
    this.userId,
    this.userRole,
    this.userName,
  });

  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (jwtToken != null && jwtToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $jwtToken';
    }

    // Backend có hỗ trợ các header này cho mobile client.
    if (userId != null && userId!.isNotEmpty) {
      headers['X-User-Id'] = userId!;
    }

    if (userRole != null && userRole!.isNotEmpty) {
      headers['X-User-Role'] = userRole!;
    }

    if (userName != null && userName!.isNotEmpty) {
      headers['X-User-Name'] = Uri.encodeComponent(userName!);
    }

    return headers;
  }

  Future<dynamic> _request(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/videoCall/$endpoint');

    late http.Response response;

    if (method == 'GET') {
      response = await http.get(
        uri,
        headers: _headers,
      );
    } else if (method == 'POST') {
      response = await http.post(
        uri,
        headers: _headers,
        body: jsonEncode(body ?? {}),
      );
    } else if (method == 'DELETE') {
      response = await http.delete(
        uri,
        headers: _headers,
      );
    } else {
      throw Exception('HTTP method không được hỗ trợ');
    }

    Map<String, dynamic> result = {};

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        result = decoded;
      }
    } catch (_) {}

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = result['message'] ??
          result['Message'] ??
          result['error'] ??
          'API lỗi ${response.statusCode}';

      throw Exception(message.toString());
    }

    return result;
  }

  Future<List<VideoCallRoom>> getRooms() async {
    final result = await _request(
      'GET',
      'rooms',
    );

    final data = result['data'] ?? result['Data'] ?? [];

    return (data as List)
        .map(
          (item) => VideoCallRoom.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  Future<VideoCallRoom> createRoom({
    required String roomName,
    int maxParticipants = 10,
    String callType = 'support',
    String? description,
  }) async {
    final result = await _request(
      'POST',
      'create-room',
      body: {
        'roomName': roomName,
        'maxParticipants': maxParticipants,
        'callType': callType,
        'description': description,
      },
    );

    final data = _responseData(result);

    if (data.isEmpty || (data['roomName'] ?? data['RoomName']) == null) {
      throw Exception('Server khong tra ve thong tin phong vua tao');
    }

    return VideoCallRoom.fromJson(
      Map<String, dynamic>.from(data),
    );
  }

  Future<VideoCallToken> joinRoom({
    required String roomName,
    String participantName = '',
    bool isAudioOnly = false,
  }) async {
    final result = await _request(
      'POST',
      'join',
      body: {
        'roomName': roomName,
        'participantName': participantName,
        'isAudioOnly': isAudioOnly,
      },
    );

    final data = _responseData(result);

    final callToken = VideoCallToken.fromJson(data);
    if (callToken.token.isEmpty || callToken.wsUrl.isEmpty || callToken.roomName.isEmpty) {
      throw Exception('Server khong tra ve du token hoac dia chi LiveKit');
    }

    return callToken;
  }

  Map<String, dynamic> _responseData(Map<String, dynamic> result) {
    final data = result['data'] ?? result['Data'] ?? result;
    return data is Map
        ? Map<String, dynamic>.from(data)
        : <String, dynamic>{};
  }

  Future<void> leaveRoom({
    required String roomName,
  }) async {
    await _request(
      'POST',
      'leave',
      body: {
        'roomName': roomName,
      },
    );
  }

  Future<VideoCallRoom> getRoomInfo({
    required String roomName,
  }) async {
    final result = await _request(
      'GET',
      'rooms/${Uri.encodeComponent(roomName)}',
    );

    final data = _responseData(result);

    if (data.isEmpty || (data['roomName'] ?? data['RoomName']) == null) {
      throw Exception('Server khong tra ve thong tin phong vua tao');
    }

    return VideoCallRoom.fromJson(
      Map<String, dynamic>.from(data),
    );
  }

  Future<List<Participant>> getParticipants({
    required String roomName,
  }) async {
    final result = await _request(
      'GET',
      'rooms/${Uri.encodeComponent(roomName)}/participants',
    );

    final data = result['data'] ?? result['Data'] ?? [];

    return (data as List)
        .map(
          (item) => Participant.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  Future<void> endRoom({
    required String roomName,
  }) async {
    await _request(
      'DELETE',
      'rooms/${Uri.encodeComponent(roomName)}',
    );
  }
}