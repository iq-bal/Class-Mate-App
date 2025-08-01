import 'package:flutter/material.dart';
import 'package:classmate/controllers/explore/explore_course_controller.dart';
import 'package:classmate/views/explore/widgets/course_card.dart';

class SearchResultSection extends StatelessWidget {
  final ExploreCourseState state;
  final ExploreCourseController controller;
  final IconData Function() getRandomIcon;
  final Color Function() getRandomColor;

  const SearchResultSection({
    super.key,
    required this.state,
    required this.controller,
    required this.getRandomIcon,
    required this.getRandomColor,
  });

  @override
  Widget build(BuildContext context) {
    if (state == ExploreCourseState.loading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state == ExploreCourseState.error) {
      return Center(
        child: Text(
          controller.errorMessage ?? 'An error occurred',
          style: const TextStyle(color: Colors.red),
        ),
      );
    } else if (state == ExploreCourseState.success && controller.courses != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Search Results", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (controller.courses!.isEmpty)
            const Center(child: Text("No courses found.", style: TextStyle(fontSize: 16)))
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: controller.courses!.map((course) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: CourseCard(
                      courseId: course.id ?? "N/A",
                      icon: getRandomIcon(),
                      title: course.title ?? "Unknown Course",
                      courseCode: course.courseCode ?? "N/A",
                      description: course.description ?? "No description available.",
                      backgroundColor: getRandomColor(),
                      isHighlighted: false,
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
