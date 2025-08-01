import 'package:classmate/views/course_overview_student/course_overview_view.dart';
import 'package:flutter/material.dart';

class CourseCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String courseCode;
  final String description;
  final Color backgroundColor;
  final bool isHighlighted;
  final String courseId;

  const CourseCard({
    super.key,
    required this.icon,
    required this.title,
    required this.courseCode,
    required this.description,
    required this.backgroundColor,
    required this.courseId, // Initialize courseId
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector( 
      onTap: () {
        // Navigate to the CourseDetailScreen and pass the courseId
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => CourseDetailScreen(courseId: courseId),
        //   ),
        // );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseOverviewView(courseId: courseId),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: isHighlighted ? 210 : 200, // Highlighted card is slightly wider
        height: isHighlighted ? 230 : 180, // Highlighted card is slightly taller
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isHighlighted
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 40),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 1, // Limit title to 1 line
              overflow: TextOverflow.ellipsis, // Add ellipsis if text is too long
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              courseCode,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              maxLines: 2, // Limit description to 2 lines
              overflow: TextOverflow.ellipsis, // Add ellipsis if text is too long
            ),
          ],
        ),
      ),
    );
  }
}
