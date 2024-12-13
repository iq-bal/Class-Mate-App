import 'package:flutter/material.dart';

class NotFoundWidget extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final double fontSize;
  final double spacing;

  const NotFoundWidget({
    super.key,
    this.emoji = '🤔', // Default emoji
    required this.title, // Title is required
    required this.subtitle, // Subtitle is required
    this.fontSize = 32.0, // Default emoji font size
    this.spacing = 6.0, // Default spacing between elements
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          emoji,
          style: TextStyle(fontSize: fontSize),
        ),
        SizedBox(height: spacing),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        SizedBox(height: spacing - 2), // Slightly reduced height
        Text(
          subtitle,
          style: const TextStyle(color: Colors.grey),
        ),
        SizedBox(height: spacing * 2),
      ],
    );
  }
}
