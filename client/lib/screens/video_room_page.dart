import 'dart:async';

import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';

import '../models/video_call_token.dart';
import '../services/livekit_call_service.dart';
import '../services/video_call_api.dart';
import '../widgets/call_control_bar.dart';

class VideoRoomPage extends StatefulWidget {
  final VideoCallApi api;
  final VideoCallToken callToken;

  const VideoRoomPage({
    super.key,
    required this.api,
    required this.callToken,
  });

  @override
  State<VideoRoomPage> createState() => _VideoRoomPageState();
}

class _VideoRoomPageState extends State<VideoRoomPage> {
  final LiveKitCallService liveKitService = LiveKitCallService();

  Timer? refreshTimer;

  bool connecting = true;
  bool microphoneEnabled = true;
  bool cameraEnabled = true;

  List<RemoteParticipant> remoteParticipants = [];

  @override
  void initState() {
    super.initState();

    connectToRoom();

    refreshTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) {
        if (mounted) {
          setState(() {
            remoteParticipants =
                liveKitService.remoteParticipants;
          });
        }
      },
    );
  }

  Future<void> connectToRoom() async {
    try {
      await liveKitService.connect(
        wsUrl: widget.callToken.wsUrl,
        token: widget.callToken.token,
        audioOnly: widget.callToken.isAudioOnly,
      );

      if (mounted) {
        setState(() {
          connecting = false;
          remoteParticipants =
              liveKitService.remoteParticipants;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          connecting = false;
        });

        showMessage(
          error.toString().replaceFirst('Exception: ', ''),
          error: true,
        );
      }
    }
  }

  void showMessage(
    String message, {
    bool error = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red : const Color(0xFF0B6E69),
      ),
    );
  }

  Future<void> toggleMicrophone() async {
    await liveKitService.toggleMicrophone();

    setState(() {
      microphoneEnabled = !microphoneEnabled;
    });
  }

  Future<void> toggleCamera() async {
    await liveKitService.toggleCamera();

    setState(() {
      cameraEnabled = !cameraEnabled;
    });
  }

  Future<void> leaveRoom() async {
    try {
      await widget.api.leaveRoom(
        roomName: widget.callToken.roomName,
      );
    } catch (_) {}

    await liveKitService.disconnect();

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    liveKitService.disconnect();
    super.dispose();
  }

  Widget buildParticipantView(Participant participant) {
    if (participant is RemoteParticipant) {
      final videoPublications = participant.videoTrackPublications;

      if (videoPublications.isNotEmpty) {
        final publication = videoPublications.first;

        if (publication.track != null) {
          return VideoTrackRenderer(
            publication.track!,
            fit: VideoViewFit.cover,
          );
        }
      }
    }

    return const Center(
      child: Icon(
        Icons.person_rounded,
        color: Colors.white54,
        size: 76,
      ),
    );
  }

  Widget buildLocalVideo() {
    final localParticipant = liveKitService.localParticipant;

    if (localParticipant == null) {
      return const SizedBox.shrink();
    }

    final videoPublications =
        localParticipant.videoTrackPublications;

    if (videoPublications.isEmpty ||
        videoPublications.first.track == null) {
      return const Center(
        child: Icon(
          Icons.person_rounded,
          color: Colors.white54,
          size: 76,
        ),
      );
    }

    return VideoTrackRenderer(
      videoPublications.first.track!,
      fit: VideoViewFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF091517),
      appBar: AppBar(
        backgroundColor: const Color(0xFF091517),
        foregroundColor: Colors.white,
        title: Text(widget.callToken.roomName),
      ),
      body: connecting
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: remoteParticipants.isEmpty
                            ? const Center(
                                child: Text(
                                  'Đang chờ người tham gia...',
                                  style: TextStyle(
                                    color: Colors.white70,
                                  ),
                                ),
                              )
                            : GridView.builder(
                                padding: const EdgeInsets.all(12),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                                itemCount: remoteParticipants.length,
                                itemBuilder: (context, index) {
                                  final participant =
                                      remoteParticipants[index];

                                  return ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(16),
                                    child: Container(
                                      color: const Color(0xFF172426),
                                      child: buildParticipantView(
                                        participant,
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),

                      Positioned(
                        right: 18,
                        top: 18,
                        width: 120,
                        height: 170,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            color: const Color(0xFF172426),
                            child: buildLocalVideo(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                CallControlBar(
                  microphoneEnabled: microphoneEnabled,
                  cameraEnabled: cameraEnabled,
                  onToggleMicrophone: toggleMicrophone,
                  onToggleCamera: toggleCamera,
                  onLeave: leaveRoom,
                ),
              ],
            ),
    );
  }
}