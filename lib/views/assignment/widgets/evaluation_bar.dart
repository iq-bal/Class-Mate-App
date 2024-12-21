import 'package:flutter/material.dart';

class EvaluationBar extends StatelessWidget {
  final String label;
  final double percentage;
  final bool isPositive; // true for green (greater is good), false for red (lesser is good)

  const EvaluationBar({
    super.key,
    required this.label,
    required this.percentage,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    final barColor = isPositive ? const Color(0xFFA1EDCD) : const Color(0xFFE57373); // Green or Red
    final backgroundColor = barColor.withOpacity(0.3); // Lighter background for the shadow effect

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Percentage Text
        Text(
          '${percentage.toStringAsFixed(0)}%',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        // Bar Container
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              height: 100,
              width: 40,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            Container(
              height: percentage,
              width: 40,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Label Text
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
