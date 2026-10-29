import 'package:flutter/material.dart';

class CallControlBar extends StatelessWidget {
  final bool microphoneEnabled;
  final bool cameraEnabled;
  final VoidCallback onToggleMicrophone;
  final VoidCallback onToggleCamera;
  final VoidCallback onLeave;

  const CallControlBar({
    super.key,
    required this.microphoneEnabled,
    required this.cameraEnabled,
    required this.onToggleMicrophone,
    required this.onToggleCamera,
    required this.onLeave,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _ControlButton(
              icon: microphoneEnabled
                  ? Icons.mic_rounded
                  : Icons.mic_off_rounded,
              onPressed: onToggleMicrophone,
            ),
            _ControlButton(
              icon: cameraEnabled
                  ? Icons.videocam_rounded
                  : Icons.videocam_off_rounded,
              onPressed: onToggleCamera,
            ),
            _ControlButton(
              icon: Icons.call_end_rounded,
              color: Colors.red,
              onPressed: onLeave,
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final VoidCallback onPressed;

  const _ControlButton({
    required this.icon,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 28,
      backgroundColor: color ?? Colors.white.withValues(alpha: 0.15),
      child: IconButton(
        onPressed: onPressed,
        color: Colors.white,
        icon: Icon(icon),
      ),
    );
  }
}