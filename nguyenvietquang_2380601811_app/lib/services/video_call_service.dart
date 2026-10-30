import '../models/video_call.dart';
import 'api_client.dart';

class VideoCallService {
  final ApiClient apiClient;
  VideoCallService({ApiClient? apiClient}) : apiClient = apiClient ?? ApiClient();

  Future<List<VideoCallRoom>> getRooms() async {
    final response = await apiClient.get('/VideoCall/rooms', auth: true);
    final data = response is Map ? response['data'] : null;
    final items = data is List ? data : <dynamic>[];
    return items.whereType<Map>().map((item) => VideoCallRoom.fromJson(Map<String, dynamic>.from(item))).toList();
  }

  Future<VideoCallRoom> createRoom({required String roomName, int maxParticipants = 10, String callType = 'support', String? description}) async {
    final response = await apiClient.post('/VideoCall/create', auth: true, body: {'roomName': roomName, 'maxParticipants': maxParticipants, 'callType': callType, 'description': description});
    return VideoCallRoom.fromJson(Map<String, dynamic>.from(response['data'] as Map));
  }

  Future<VideoCallToken> joinRoom({required String roomName, required String participantName, bool isAudioOnly = false}) async {
    final response = await apiClient.post('/VideoCall/join', auth: true, body: {'roomName': roomName, 'participantName': participantName, 'isAudioOnly': isAudioOnly});
    return VideoCallToken.fromJson(Map<String, dynamic>.from(response['data'] as Map));
  }

  Future<void> leaveRoom({required String roomName}) async {
    await apiClient.post('/VideoCall/leave', auth: true, body: {'roomName': roomName});
  }

  Future<void> endRoom({required String roomName}) async {
    await apiClient.post('/VideoCall/end', auth: true, body: {'roomName': roomName});
  }
}
