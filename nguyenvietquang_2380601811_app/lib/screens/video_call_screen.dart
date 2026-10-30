import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import '../controllers/video_call_controller.dart';
import '../models/video_call.dart';
import 'video_call_room_screen.dart';

class VideoCallScreen extends StatefulWidget {
  final AuthController authController;

  const VideoCallScreen({super.key, required this.authController});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final controller = VideoCallController();
  final roomNameController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.loadRooms();
  }

  @override
  void dispose() {
    roomNameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createRoom() async {
    if (roomNameController.text.trim().isEmpty) {
      _showMessage('Vui lòng nhập tên phòng.');
      return;
    }
    final room = await controller.createRoom(
      roomName: roomNameController.text.trim(),
      maxParticipants: 10,
      callType: 'support',
      description: descriptionController.text.trim(),
    );
    if (!mounted) return;
    if (room != null) {
      Navigator.pop(context);
      _showMessage('Đã tạo phòng ${room.roomName}');
      roomNameController.clear();
      descriptionController.clear();
    } else {
      _showMessage(controller.errorMessage ?? 'Không thể tạo phòng.');
    }
  }

  Future<void> _joinRoom(VideoCallRoom room) async {
    final user = widget.authController.currentUser!;
    final token = await controller.joinRoom(
      roomName: room.roomName,
      participantName: user.fullName,
      isAudioOnly: false,
    );
    if (!mounted) return;
    if (token != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VideoCallRoomScreen(
            token: token,
            room: room,
            onLeave: () => controller.leaveRoom(roomName: room.roomName),
          ),
        ),
      );
    } else {
      _showMessage(controller.errorMessage ?? 'Không thể tham gia phòng.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(SnackBar(content: Text(message)));
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tạo phòng video call'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: roomNameController,
              decoration: const InputDecoration(labelText: 'Tên phòng', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Mô tả (không bắt buộc)', border: OutlineInputBorder()),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          FilledButton(onPressed: _createRoom, child: const Text('Tạo')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Call'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: controller.loadRooms),
        ],
      ),
      body: ListenableBuilder(
        listenable: controller,
        builder: (_, __) {
          if (controller.isLoading) return const Center(child: CircularProgressIndicator());
          return RefreshIndicator(
            onRefresh: controller.loadRooms,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (controller.errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                    child: Text(controller.errorMessage!, style: TextStyle(color: Colors.red.shade900)),
                  ),
                Text('Phòng khả dụng', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                if (controller.rooms.isEmpty)
                  const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('Chưa có phòng nào')))
                else
                  ...controller.rooms.map((room) => _RoomCard(room: room, onJoin: () => _joinRoom(room), onEnd: widget.authController.isAdmin ? () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Kết thúc phòng'),
                        content: Text('Bạn có chắc muốn kết thúc phòng "${room.roomName}"?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
                          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Kết thúc')),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      final success = await controller.endRoom(roomName: room.roomName);
                      if (mounted) _showMessage(success ? 'Đã kết thúc phòng' : 'Không thể kết thúc phòng');
                    }
                  } : null)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        icon: const Icon(Icons.add),
        label: const Text('Tạo phòng'),
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final VideoCallRoom room;
  final VoidCallback onJoin;
  final VoidCallback? onEnd;

  const _RoomCard({required this.room, required this.onJoin, this.onEnd});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.video_call, color: Colors.blue.shade700),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(room.roomName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text('${room.currentParticipants}/${room.maxParticipants} người', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: room.isActive ? Colors.green.shade100 : Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                  child: Text(room.isActive ? 'Hoạt động' : 'Không hoạt động', style: TextStyle(color: room.isActive ? Colors.green.shade900 : Colors.grey.shade700, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            if (room.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(room.description, style: TextStyle(color: Colors.grey.shade700)),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: FilledButton.icon(onPressed: room.isActive ? onJoin : null, icon: const Icon(Icons.video_call, size: 20), label: const Text('Tham gia'))),
                if (onEnd != null) ...[
                  const SizedBox(width: 8),
                  OutlinedButton(onPressed: onEnd, style: OutlinedButton.styleFrom(foregroundColor: Colors.red), child: const Text('Kết thúc')),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
