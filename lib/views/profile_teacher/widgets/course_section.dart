import 'package:flutter/material.dart';
import 'package:classmate/views/create_course/create_course_screen.dart';
import 'course_card.dart';

class CoursesSection extends StatelessWidget {
  final List<UICourse> courses;
  final Function(String)? onDeleteCourse;

  const CoursesSection({
    super.key,
    required this.courses,
    this.onDeleteCourse,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Courses Taught',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'View All',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // If no courses, show the full‐width “Create a Course” card
        if (courses.isEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
              ),
              child: Center(
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CreateCourseScreen()),
                    );
                  },
                  icon: const Icon(Icons.add_circle_outline, size: 28, color: Colors.blueAccent),
                  label: const Text(
                    'Create a Course',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.blueAccent,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.blueAccent.withOpacity(0.1),
                  ),
                ),
              ),
            ),
          ),
        ] else ...[
          // Otherwise, show horizontal list AND an extra "create" card at the end
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: courses.length + 1,
              itemBuilder: (context, index) {
                if (index < courses.length) {
                  final course = courses[index];
                  return CourseCard(
                    id: course.id,
                    title: course.title,
                    imagePath: course.imagePath,
                    onDelete: onDeleteCourse ?? (_) {},
                  );
                } else {
                  // the "create course" card matching CourseCard dimensions
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CreateCourseScreen()),
                      );
                    },
                    child: Container(
                      width: 140,
                      margin: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.blue.shade50,
                        border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add, size: 32, color: Colors.blueAccent),
                            SizedBox(height: 8),
                            Text(
                              'Create Course',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.blueAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ],
    );
  }
}

class UICourse {
  final String id;
  final String title;
  final String imagePath;

  UICourse({required this.id, required this.title, required this.imagePath});
}
