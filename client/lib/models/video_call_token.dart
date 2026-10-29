class VideoCallToken {
  final String token;
  final String wsUrl;
  final String roomName;
  final String participantName;
  final String participantRole;
  final String callType;
  final bool isAudioOnly;
  final DateTime? expiresAt;

  const VideoCallToken({
    required this.token,
    required this.wsUrl,
    required this.roomName,
    required this.participantName,
    required this.participantRole,
    required this.callType,
    required this.isAudioOnly,
    required this.expiresAt,
  });

  factory VideoCallToken.fromJson(Map<String, dynamic> json) {
    return VideoCallToken(
      token: (json['token'] ?? json['Token'] ?? '').toString(),
      wsUrl: (json['wsUrl'] ?? json['WsUrl'] ?? '').toString(),
      roomName: (json['roomName'] ?? json['RoomName'] ?? '').toString(),
      participantName:
          (json['participantName'] ?? json['ParticipantName'] ?? '')
              .toString(),
      participantRole:
          (json['participantRole'] ?? json['ParticipantRole'] ?? '')
              .toString(),
      callType: (json['callType'] ?? json['CallType'] ?? 'support').toString(),
      isAudioOnly: json['isAudioOnly'] ?? json['IsAudioOnly'] ?? false,
      expiresAt: DateTime.tryParse(
        (json['expiresAt'] ?? json['ExpiresAt'] ?? '').toString(),
      ),
    );
  }
}