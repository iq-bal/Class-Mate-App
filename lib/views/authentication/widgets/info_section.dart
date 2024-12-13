import 'package:flutter/material.dart';

class InfoSection extends StatelessWidget {
  final String title;
  final String subtitle;

  const InfoSection({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Raleway',
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Center(
          child: Text(
            subtitle,
            style: const TextStyle(
              fontFamily: 'Raleway',
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
