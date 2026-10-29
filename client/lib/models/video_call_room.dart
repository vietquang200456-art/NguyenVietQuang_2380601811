import 'participant.dart';

class VideoCallRoom {
  final String roomName;
  final int maxParticipants;
  final int currentParticipants;
  final DateTime? createdAt;
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

  factory VideoCallRoom.fromJson(Map<String, dynamic> json) {
    final rawParticipants =
        json['participants'] ?? json['Participants'] ?? [];

    return VideoCallRoom(
      roomName: (json['roomName'] ?? json['RoomName'] ?? '').toString(),
      maxParticipants:
          json['maxParticipants'] ?? json['MaxParticipants'] ?? 10,
      currentParticipants:
          json['currentParticipants'] ?? json['CurrentParticipants'] ?? 0,
      createdAt: DateTime.tryParse(
        (json['createdAt'] ?? json['CreatedAt'] ?? '').toString(),
      ),
      isActive: json['isActive'] ?? json['IsActive'] ?? false,
      createdByUserId:
          json['createdByUserId'] ?? json['CreatedByUserId'] ?? 0,
      createdByName:
          (json['createdByName'] ?? json['CreatedByName'] ?? '').toString(),
      createdByRole:
          (json['createdByRole'] ?? json['CreatedByRole'] ?? '').toString(),
      callType: (json['callType'] ?? json['CallType'] ?? 'support').toString(),
      description:
          (json['description'] ?? json['Description'] ?? '').toString(),
      participants: (rawParticipants as List)
          .map(
            (item) => Participant.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
    );
  }
}