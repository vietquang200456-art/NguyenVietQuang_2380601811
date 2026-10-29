import 'package:flutter/material.dart';

import '../models/video_call_room.dart';
import '../models/video_call_token.dart';
import '../services/video_call_api.dart';
import '../widgets/room_card.dart';
import 'video_room_page.dart';

class VideoHomePage extends StatefulWidget {
  final String? token;
  final String? userId;
  final String? userRole;
  final String? userName;

  const VideoHomePage({
    super.key,
    this.token,
    this.userId,
    this.userRole,
    this.userName,
  });

  @override
  State<VideoHomePage> createState() => _VideoHomePageState();
}

class _VideoHomePageState extends State<VideoHomePage> {
  final roomController = TextEditingController();
  List<VideoCallRoom> rooms = [];
  bool loading = true;
  late final VideoCallApi api;

  @override
  void initState() {
    super.initState();
    api = VideoCallApi(
      jwtToken: widget.token,
      userId: widget.userId,
      userRole: widget.userRole ?? 'User',
      userName: widget.userName ?? 'Người dùng',
    );
    loadRooms();
  }

  @override
  void dispose() {
    roomController.dispose();
    super.dispose();
  }

  void showMessage(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red : const Color(0xFF0B6E69),
      ),
    );
  }

  Future<void> loadRooms() async {
    setState(() => loading = true);
    try {
      final result = await api.getRooms();
      if (mounted) setState(() => rooms = result);
    } catch (error) {
      if (mounted) {
        showMessage(
          error.toString().replaceFirst('Exception: ', ''),
          error: true,
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> createRoom() async {
    final name = TextEditingController();
    final description = TextEditingController();
    final maxParticipants = TextEditingController(text: '10');

    final created = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tạo phòng video'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(
                  labelText: 'Tên phòng',
                  hintText: 'phong-ho-tro-ky-thuat',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: maxParticipants,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Số người tối đa',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: description,
                decoration: const InputDecoration(
                  labelText: 'Mô tả phòng',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () async {
              final roomName = name.text.trim();
              final limit = int.tryParse(maxParticipants.text) ?? 10;

              if (roomName.isEmpty) {
                showMessage('Vui lòng nhập tên phòng', error: true);
                return;
              }

              if (limit < 2 || limit > 100) {
                showMessage('Số người phải từ 2 đến 100', error: true);
                return;
              }

              try {
                await api.createRoom(
                  roomName: roomName,
                  maxParticipants: limit,
                  callType: 'support',
                  description: description.text.trim(),
                );

                if (context.mounted) {
                  Navigator.pop(context, true);
                }
              } catch (error) {
                if (context.mounted) {
                  showMessage(
                    error.toString().replaceFirst('Exception: ', ''),
                    error: true,
                  );
                }
              }
            },
            child: const Text('Tạo phòng'),
          ),
        ],
      ),
    );

    name.dispose();
    description.dispose();
    maxParticipants.dispose();

    if (created == true) {
      await loadRooms();
      showMessage('Tạo phòng video thành công');
    }
  }

  Future<void> joinRoom(VideoCallRoom room) async {
    try {
      final callToken = await api.joinRoom(
        roomName: room.roomName,
        participantName: widget.userName ?? 'Người dùng',
        isAudioOnly: false,
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VideoRoomPage(
            api: api,
            callToken: callToken,
          ),
        ),
      );
    } catch (error) {
      showMessage(
        error.toString().replaceFirst('Exception: ', ''),
        error: true,
      );
    }
  }

  Future<void> joinByName() async {
    final name = roomController.text.trim();
    if (name.isEmpty) {
      showMessage('Vui lòng nhập tên phòng', error: true);
      return;
    }

    try {
      final callToken = await api.joinRoom(
        roomName: name,
        participantName: widget.userName ?? 'Người dùng',
        isAudioOnly: false,
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VideoRoomPage(
            api: api,
            callToken: callToken,
          ),
        ),
      );
    } catch (error) {
      showMessage(
        error.toString().replaceFirst('Exception: ', ''),
        error: true,
      );
    }
  }

  Future<void> endRoom(VideoCallRoom room) async {
    try {
      await api.endRoom(roomName: room.roomName);
      await loadRooms();
      showMessage('Đã kết thúc phòng ${room.roomName}');
    } catch (error) {
      showMessage(
        error.toString().replaceFirst('Exception: ', ''),
        error: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gọi video',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            onPressed: loadRooms,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: createRoom,
        icon: const Icon(Icons.add_call),
        label: const Text('Tạo phòng'),
      ),
      body: RefreshIndicator(
        onRefresh: loadRooms,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: roomController,
                        decoration: const InputDecoration(
                          labelText: 'Nhập tên phòng để tham gia',
                          prefixIcon: Icon(Icons.meeting_room_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: joinByName,
                      icon: const Icon(Icons.login_rounded),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (loading)
              const Center(child: CircularProgressIndicator())
            else if (rooms.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 100),
                child: Center(child: Text('Chưa có phòng video nào')),
              )
            else
              ...rooms.map(
                (room) => RoomCard(
                  room: room,
                  onJoin: () => joinRoom(room),
                  onEnd: () => endRoom(room),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
