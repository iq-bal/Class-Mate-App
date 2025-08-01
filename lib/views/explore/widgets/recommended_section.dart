import 'package:classmate/models/explore/course_card_model.dart';
import 'package:flutter/material.dart';
import 'package:classmate/views/explore/widgets/course_card.dart';

class RecommendedSection extends StatelessWidget {
  final IconData Function() getRandomIcon;
  final Color Function() getRandomColor;
  final List<CourseCardModel> courses;

  const RecommendedSection({
    super.key,
    required this.getRandomIcon,
    required this.getRandomColor,
    required this.courses,
  });

  @override
  Widget build(BuildContext context) {
    if (courses.isEmpty) {
      return const Center(child: Text("No recommended courses available"));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Recommended for you", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: courses.map((course) {
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: CourseCard(
                  courseId: course.id,
                  icon: getRandomIcon(),
                  title: course.title,
                  courseCode: course.courseCode,
                  description: course.excerpt ?? "No description available",
                  backgroundColor: getRandomColor(),
                  isHighlighted: false,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
