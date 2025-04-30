import 'package:classmate/views/class_details_student/class_details_student_view.dart';
import 'package:classmate/views/home/widgets/home_header.dart';
import 'package:classmate/views/home/widgets/next_class_card.dart';
import 'package:classmate/views/home/widgets/assignment_card.dart';
import 'package:classmate/views/home/widgets/class_test_card.dart';
import 'package:classmate/views/home/widgets/section_header.dart'; // <--- NEW
import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HomeHeader(),

          const SizedBox(height: 16),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(title: "Next Classes", onSeeAll: () {}),
                  const SizedBox(height: 12),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: List.generate(3, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 0),
                          child: NextClassCard(
                            title: "Advanced Algorithms",
                            teacherName: "Abdul Aziz",
                            timeRange: "9:00 - 10:00 AM",
                            icon: Icons.school,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ClassDetailsStudent(
                                    courseId: "675c9104b6f24d432eb28707",
                                    day: "Friday",
                                    teacherId: "67700aaf73eeab1f443ac463",
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 16),
                  SectionHeader(title: "Assignment", onSeeAll: () {}),
                  const SizedBox(height: 12),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return const AssignmentCard();
                    },
                  ),

                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "Class Tests",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  const ClassTestCard(
                    testName: "Image Processing",
                    isSelected: true,
                  ),
                  const ClassTestCard(
                    testName: "Natural Language Processing",
                    isSelected: false,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
