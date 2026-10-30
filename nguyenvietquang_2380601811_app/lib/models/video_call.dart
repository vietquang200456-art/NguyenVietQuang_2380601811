class VideoCallRoom {
  final String roomName;
  final int maxParticipants;
  final int currentParticipants;
  final DateTime createdAt;
  final bool isActive;
  final int createdByUserId;
  final String createdByName;
  final String createdByRole;
  final String callType;
  final String description;
  final List<Participant> participants;

  const VideoCallRoom({
    required this.roomName,
    required this.maxParticipants,
    required this.currentParticipants,
    required this.createdAt,
    required this.isActive,
    required this.createdByUserId,
    required this.createdByName,
    required this.createdByRole,
    required this.callType,
    required this.description,
    required this.participants,
  });

  factory VideoCallRoom.fromJson(Map<String, dynamic> json) => VideoCallRoom(
    roomName: '${json['roomName'] ?? ''}',
    maxParticipants: _int(json['maxParticipants']),
    currentParticipants: _int(json['currentParticipants']),
    createdAt: _date(json['createdAt']) ?? DateTime.now(),
    isActive: json['isActive'] == true,
    createdByUserId: _int(json['createdByUserId']),
    createdByName: '${json['createdByName'] ?? ''}',
    createdByRole: '${json['createdByRole'] ?? ''}',
    callType: '${json['callType'] ?? 'support'}',
    description: '${json['description'] ?? ''}',
    participants: (json['participants'] as List?)?.map((p) => Participant.fromJson(p)).toList() ?? [],
  );

  static int _int(dynamic v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;
  static DateTime? _date(dynamic v) => v == null ? null : DateTime.tryParse('$v');
}

class Participant {
  final String identity;
  final String name;
  final String role;
  final DateTime joinedAt;
  final bool isConnected;

  const Participant({required this.identity, required this.name, required this.role, required this.joinedAt, required this.isConnected});

  factory Participant.fromJson(Map<String, dynamic> json) => Participant(
    identity: '${json['identity'] ?? ''}',
    name: '${json['name'] ?? ''}',
    role: '${json['role'] ?? ''}',
    joinedAt: DateTime.tryParse('${json['joinedAt']}') ?? DateTime.now(),
    isConnected: json['isConnected'] == true,
  );
}

class VideoCallToken {
  final String token;
  final String wsUrl;
  final String roomName;
  final String participantName;
  final String participantRole;
  final String callType;
  final bool isAudioOnly;
  final DateTime expiresAt;

  const VideoCallToken({required this.token, required this.wsUrl, required this.roomName, required this.participantName, required this.participantRole, required this.callType, required this.isAudioOnly, required this.expiresAt});

  factory VideoCallToken.fromJson(Map<String, dynamic> json) => VideoCallToken(
    token: '${json['token'] ?? ''}',
    wsUrl: '${json['wsUrl'] ?? ''}',
    roomName: '${json['roomName'] ?? ''}',
    participantName: '${json['participantName'] ?? ''}',
    participantRole: '${json['participantRole'] ?? ''}',
    callType: '${json['callType'] ?? 'support'}',
    isAudioOnly: json['isAudioOnly'] == true,
    expiresAt: DateTime.tryParse('${json['expiresAt']}') ?? DateTime.now(),
  );
}
