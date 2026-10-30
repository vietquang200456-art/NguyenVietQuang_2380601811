import 'package:flutter/foundation.dart';
import '../models/video_call.dart';
import '../services/video_call_service.dart';

class VideoCallController extends ChangeNotifier {
  final VideoCallService service;
  VideoCallController({VideoCallService? service}) : service = service ?? VideoCallService();

  List<VideoCallRoom> rooms = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadRooms() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      rooms = await service.getRooms();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<VideoCallRoom?> createRoom({required String roomName, int maxParticipants = 10, String callType = 'support', String? description}) async {
    try {
      final room = await service.createRoom(roomName: roomName, maxParticipants: maxParticipants, callType: callType, description: description);
      await loadRooms();
      return room;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<VideoCallToken?> joinRoom({required String roomName, required String participantName, bool isAudioOnly = false}) async {
    try {
      return await service.joinRoom(roomName: roomName, participantName: participantName, isAudioOnly: isAudioOnly);
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> leaveRoom({required String roomName}) async {
    try {
      await service.leaveRoom(roomName: roomName);
      await loadRooms();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> endRoom({required String roomName}) async {
    try {
      await service.endRoom(roomName: roomName);
      await loadRooms();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
