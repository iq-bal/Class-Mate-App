import 'package:flutter/material.dart';

class RecentActivities extends StatelessWidget {
  const RecentActivities({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Activities',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            itemBuilder: (context, index) {
              return ActivityItem(
                activity: _getMockActivity(index),
                time: _getMockTime(index),
                icon: _getMockIcon(index),
                color: _getMockColor(index),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getMockActivity(int index) {
    switch (index) {
      case 0:
        return 'John Doe submitted Assignment 3';
      case 1:
        return 'New student enrolled in Advanced Algorithms';
      case 2:
        return 'Posted new assignment in Database Systems';
      case 3:
        return 'Updated course materials for Software Engineering';
      default:
        return '';
    }
  }

  String _getMockTime(int index) {
    switch (index) {
      case 0:
        return '2 minutes ago';
      case 1:
        return '1 hour ago';
      case 2:
        return '3 hours ago';
      case 3:
        return '5 hours ago';
      default:
        return '';
    }
  }

  IconData _getMockIcon(int index) {
    switch (index) {
      case 0:
        return Icons.assignment_turned_in;
      case 1:
        return Icons.person_add;
      case 2:
        return Icons.post_add;
      case 3:
        return Icons.update;
      default:
        return Icons.circle;
    }
  }

  Color _getMockColor(int index) {
    switch (index) {
      case 0:
        return Colors.green;
      case 1:
        return Colors.blue;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}

class ActivityItem extends StatelessWidget {
  final String activity;
  final String time;
  final IconData icon;
  final Color color;

  const ActivityItem({
    super.key,
    required this.activity,
    required this.time,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
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