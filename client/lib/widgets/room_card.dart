import 'package:flutter/material.dart';

import '../models/video_call_room.dart';

class RoomCard extends StatelessWidget {
  final VideoCallRoom room;
  final VoidCallback onJoin;
  final VoidCallback onEnd;

  const RoomCard({
    super.key,
    required this.room,
    required this.onJoin,
    required this.onEnd,
  });

  @override
  Widget build(BuildContext context) {
    final bool isFull =
        room.currentParticipants >= room.maxParticipants;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFFE1F3ED),
                  child: Icon(
                    Icons.video_call_rounded,
                    color: Color(0xFF0B6E69),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    room.roomName,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Chip(
                  label: Text(
                    room.isActive ? 'Đang hoạt động' : 'Đã đóng',
                  ),
                  backgroundColor: room.isActive
                      ? Colors.green.shade50
                      : Colors.grey.shade200,
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              room.description.isEmpty
                  ? 'Phòng hỗ trợ cuộc gọi'
                  : room.description,
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                const Icon(Icons.people_outline, size: 18),
                const SizedBox(width: 6),
                Text(
                  '${room.currentParticipants}/${room.maxParticipants} người',
                ),
                const SizedBox(width: 18),
                Text(
                  room.callType,
                  style: const TextStyle(
                    color: Color(0xFF0B6E69),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: room.isActive && !isFull ? onJoin : null,
                    icon: const Icon(Icons.login_rounded),
                    label: const Text('Tham gia'),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: onEnd,
                  child: const Text('Kết thúc'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}