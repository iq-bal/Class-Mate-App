import 'package:flutter/material.dart';

class ParticipantsSelector extends StatelessWidget {
  final List<Map<String, String>> participants;
  final VoidCallback onAddParticipant;
  final Function(Map<String, String>) onRemoveParticipant;

  const ParticipantsSelector({
    Key? key,
    required this.participants,
    required this.onAddParticipant,
    required this.onRemoveParticipant,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onAddParticipant,
          child: const CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white,
            child: Icon(Icons.add, color: Colors.teal),
          ),
        ),
        const SizedBox(width: 12),
        ...participants.map((participant) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: CircleAvatar(
                  radius: 24,
                  backgroundImage: AssetImage(participant["avatar"]!),
                ),
              ),
              Positioned(
                top: -6,
                right: -6,
                child: GestureDetector(
                  onTap: () => onRemoveParticipant(participant),
                  child: const CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.red,
                    child: Icon(Icons.close, color: Colors.white, size: 14),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }
}
