import 'package:flutter/material.dart';
import 'package:classmate/core/design/app_theme.dart';

class InfoSection extends StatelessWidget {
  const InfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.person_outline,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Personal Information',
                  style: AppTheme.titleLarge,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          InfoItem(
            icon: Icons.email_outlined,
            title: 'Email',
            value: 'john.doe@university.edu',
            onTap: () {},
          ),
          InfoItem(
            icon: Icons.phone_outlined,
            title: 'Phone',
            value: '+1 234 567 8900',
            onTap: () {},
          ),
          InfoItem(
            icon: Icons.school_outlined,
            title: 'Department',
            value: 'Computer Science',
            onTap: () {},
          ),
          InfoItem(
            icon: Icons.location_on_outlined,
            title: 'Office',
            value: 'Room 401, Building A',
            onTap: () {},
            showDivider: false,
          ),
        ],
      ),
    );
  }
}

class InfoItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;
  final bool showDivider;

  const InfoItem({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: AppTheme.primaryColor, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTheme.bodyMedium),
                      const SizedBox(height: 4),
                      Text(value, style: AppTheme.titleMedium),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
        if (showDivider) const Divider(height: 1),
      ],
    );
  }
} 