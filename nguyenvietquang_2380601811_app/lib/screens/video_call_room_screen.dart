import 'package:flutter/material.dart';
import 'dart:async';
import '../models/video_call.dart';

class VideoCallRoomScreen extends StatefulWidget {
  final VideoCallToken token;
  final VideoCallRoom room;
  final Future<void> Function() onLeave;

  const VideoCallRoomScreen({super.key, required this.token, required this.room, required this.onLeave});

  @override
  State<VideoCallRoomScreen> createState() => _VideoCallRoomScreenState();
}

class _VideoCallRoomScreenState extends State<VideoCallRoomScreen> {
  bool isMuted = false;
  bool isVideoOff = false;
  Timer? _timer;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() => _seconds++));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    return h > 0 ? '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}' : '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _leave() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rời phòng'),
        content: const Text('Bạn có chắc muốn rời phòng?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Ở lại')),
          FilledButton(onPressed: () => Navigator.pop(context, true), style: FilledButton.styleFrom(backgroundColor: Colors.red), child: const Text('Rời phòng')),
        ],
      ),
    );
    if (confirmed == true) {
      await widget.onLeave();
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Video placeholder
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(color: Colors.blue.shade700, shape: BoxShape.circle),
                    child: const Icon(Icons.person, size: 60, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(widget.token.participantName, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(widget.room.roomName, style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
                ],
              ),
            ),
            // Top bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(0.7), Colors.transparent])),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.fiber_manual_record, color: Colors.white, size: 12),
                          const SizedBox(width: 6),
                          Text(_formatDuration(_seconds), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text('${widget.room.currentParticipants} người', style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
            // Participants grid (placeholder)
            Positioned(
              top: 80,
              right: 16,
              child: Column(
                children: widget.room.participants.where((p) => p.isConnected).take(3).map((p) => Container(
                  width: 80,
                  height: 100,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(color: Colors.grey.shade800, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.person, color: Colors.white, size: 32),
                      const SizedBox(height: 4),
                      Text(p.name.split(' ').last, style: const TextStyle(color: Colors.white, fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                )).toList(),
              ),
            ),
            // Controls
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
                decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black.withOpacity(0.9), Colors.transparent])),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ControlButton(
                      icon: isMuted ? Icons.mic_off : Icons.mic,
                      label: isMuted ? 'Tắt mic' : 'Bật mic',
                      color: isMuted ? Colors.red : Colors.white,
                      onTap: () => setState(() => isMuted = !isMuted),
                    ),
                    _ControlButton(
                      icon: isVideoOff ? Icons.videocam_off : Icons.videocam,
                      label: isVideoOff ? 'Tắt camera' : 'Bật camera',
                      color: isVideoOff ? Colors.red : Colors.white,
                      onTap: () => setState(() => isVideoOff = !isVideoOff),
                    ),
                    _ControlButton(
                      icon: Icons.call_end,
                      label: 'Rời phòng',
                      color: Colors.white,
                      backgroundColor: Colors.red,
                      onTap: _leave,
                    ),
                    _ControlButton(
                      icon: Icons.more_vert,
                      label: 'Thêm',
                      color: Colors.white,
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tính năng đang được phát triển'))),
                    ),
                  ],
                ),
              ),
            ),
            // Info banner
            Positioned(
              top: 140,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.blue.shade900.withOpacity(0.9), borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Chức năng video call đang ở chế độ demo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Token: ${widget.token.token.substring(0, 20)}...', style: TextStyle(color: Colors.grey.shade300, fontSize: 12)),
                    Text('WebSocket: ${widget.token.wsUrl}', style: TextStyle(color: Colors.grey.shade300, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color? backgroundColor;
  final VoidCallback onTap;

  const _ControlButton({required this.icon, required this.label, required this.color, this.backgroundColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: backgroundColor ?? Colors.grey.shade800, shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: Colors.grey.shade300, fontSize: 12)),
        ],
      ),
    );
  }
}
