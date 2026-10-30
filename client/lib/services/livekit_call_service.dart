import 'package:livekit_client/livekit_client.dart';

class LiveKitCallService {
  Room? room;

  Future<void> connect({
    required String wsUrl,
    required String token,
    required bool audioOnly,
  }) async {
    final normalizedUrl = wsUrl.trim();
    final normalizedToken = token.trim();

    if (normalizedUrl.isEmpty || normalizedToken.isEmpty) {
      throw Exception('Thieu LiveKit URL hoac token ket noi');
    }

    if (!normalizedUrl.startsWith('ws://') &&
        !normalizedUrl.startsWith('wss://')) {
      throw Exception('LiveKit URL khong hop le: $normalizedUrl');
    }

    await disconnect();
    room = Room();

    await room!.connect(
      normalizedUrl,
      normalizedToken,
      roomOptions: RoomOptions(
        adaptiveStream: true,
        dynacast: true,
      ),
    );

    final participant = room!.localParticipant;
    if (participant == null) {
      throw Exception('LiveKit khong tao duoc nguoi tham gia cuc bo');
    }

    await participant.setMicrophoneEnabled(true);
    await participant.setCameraEnabled(!audioOnly);
  }

  Future<void> toggleMicrophone() async {
    final participant = room?.localParticipant;

    if (participant == null) return;

    final isEnabled = participant.isMicrophoneEnabled();
    await participant.setMicrophoneEnabled(!isEnabled);
  }

  Future<void> toggleCamera() async {
    final participant = room?.localParticipant;

    if (participant == null) return;

    final isEnabled = participant.isCameraEnabled();
    await participant.setCameraEnabled(!isEnabled);
  }

  Future<void> disconnect() async {
    await room?.disconnect();
    await room?.dispose();
    room = null;
  }

  List<RemoteParticipant> get remoteParticipants {
    return room?.remoteParticipants.values.toList() ?? [];
  }

  LocalParticipant? get localParticipant {
    return room?.localParticipant;
  }
}