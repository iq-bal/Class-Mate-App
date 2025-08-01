import 'package:flutter/material.dart';

class InProgressSection extends StatelessWidget {
  const InProgressSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("In progress", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              Icon(Icons.timer, size: 40),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Visual Design", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text("10 lessons left"),
                ],
              ),
              Spacer(),
              Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ],
    );
  }
}
