import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:livekit_client/livekit_client.dart';

class LiveKitCallService {
  Room? room;

  Future<void> connect({
    required String wsUrl,
    required String token,
    required bool audioOnly,
  }) async {
    room = Room();

    await room!.connect(
      wsUrl,
      token,
      roomOptions: RoomOptions(
        adaptiveStream: true,
        dynacast: true,
      ),
    );

    await room!.localParticipant?.setCameraEnabled(!audioOnly);
    await room!.localParticipant?.setMicrophoneEnabled(true);
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