import 'package:flutter/material.dart';

import '../models/participant.dart';

class ParticipantTile extends StatelessWidget {
  final Participant participant;

  const ParticipantTile({
    super.key,
    required this.participant,
  });

  @override
  Widget build(BuildContext context) {
    final String displayName = participant.name.isEmpty
        ? participant.identity
        : participant.name;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF172426),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          const Center(
            child: Icon(
              Icons.person_rounded,
              size: 64,
              color: Colors.white54,
            ),
          ),
          Positioned(
            left: 10,
            right: 10,
            bottom: 10,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    displayName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  participant.role,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}