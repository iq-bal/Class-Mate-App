import 'package:flutter/material.dart';
import 'package:classmate/core/design/app_theme.dart';

class TodaySchedule extends StatelessWidget {
  const TodaySchedule({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Today\'s Schedule', style: AppTheme.titleLarge),
            TextButton(
              onPressed: () {},
              child: Row(
                children: [
                  Text(
                    'View All',
                    style: TextStyle(
                      color: AppTheme.primaryColor.withOpacity(0.8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: AppTheme.primaryColor.withOpacity(0.8),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const ScheduleCard(
          courseCode: 'CS101',
          courseName: 'Introduction to Programming',
          timeSlot: '09:00 AM - 10:30 AM',
          room: 'Room 401',
          students: 32,
          color: AppTheme.primaryColor,
          isOngoing: true,
        ),
        const SizedBox(height: 16),
        const ScheduleCard(
          courseCode: 'CS202',
          courseName: 'Data Structures',
          timeSlot: '11:00 AM - 12:30 PM',
          room: 'Room 405',
          students: 28,
          color: AppTheme.accentColor,
          isOngoing: false,
        ),
      ],
    );
  }
}

class ScheduleCard extends StatelessWidget {
  final String courseCode;
  final String courseName;
  final String timeSlot;
  final String room;
  final int students;
  final Color color;
  final bool isOngoing;

  const ScheduleCard({
    super.key,
    required this.courseCode,
    required this.courseName,
    required this.timeSlot,
    required this.room,
    required this.students,
    required this.color,
    required this.isOngoing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              courseCode,
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (isOngoing) ...[
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.successColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: AppTheme.successColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Ongoing',
                                    style: TextStyle(
                                      color: AppTheme.successColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () {},
                      color: Colors.grey[400],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  courseName,
                  style: AppTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildInfoItem(Icons.access_time, timeSlot),
                      const SizedBox(width: 24),
                      _buildInfoItem(Icons.room, room),
                      const SizedBox(width: 24),
                      _buildInfoItem(Icons.people, '$students students'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: AppTheme.bodyMedium.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
} 