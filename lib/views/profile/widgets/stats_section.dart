import 'package:flutter/material.dart';
import 'package:classmate/core/design/app_theme.dart';

class StatsSection extends StatelessWidget {
  const StatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            StatItem(
              value: '8',
              label: 'Courses',
              color: AppTheme.primaryColor,
            ),
            VerticalDivider(
              color: Color(0xFFE2E8F0),
              thickness: 1,
            ),
            StatItem(
              value: '126',
              label: 'Students',
              color: AppTheme.successColor,
            ),
            VerticalDivider(
              color: Color(0xFFE2E8F0),
              thickness: 1,
            ),
            StatItem(
              value: '95%',
              label: 'Rating',
              color: AppTheme.warningColor,
            ),
          ],
        ),
      ),
    );
  }
}

class StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const StatItem({
    super.key,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTheme.bodyMedium,
        ),
      ],
    );
  }
} 