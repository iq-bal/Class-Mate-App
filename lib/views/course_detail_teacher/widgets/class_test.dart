import 'package:flutter/material.dart';
import 'package:classmate/views/course_detail_teacher/widgets/class_test_card.dart';
import 'package:classmate/views/course_detail_teacher/widgets/not_found.dart';

class ClassTest {
  final String id;
  final String title;
  final String description;
  final String date;
  final String iconText;
  final int duration;
  final int totalMarks;

  ClassTest({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.iconText,
    required this.duration,
    required this.totalMarks,
  });
}

class ClassTestContainer extends StatelessWidget {
  final List<ClassTest> classTests;
  final VoidCallback onCreateClassTest;

  const ClassTestContainer({
    super.key,
    required this.classTests,
    required this.onCreateClassTest,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Aligns text and container to the left
      children: [
        const Text(
          'Active Class Tests',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity, // Makes the container take the full width
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 0), // Reduced vertical padding
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFD9D9D9)), // Border color
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // Centers the content horizontally
            children: [
              if (classTests.isEmpty)
                const NotFoundWidget(
                  emoji: '📝',
                  title: 'Class Test Not Found',
                  subtitle: 'You don\'t have active class tests',
                )
              else
                Column(
                  children: classTests
                      .map(
                        (classTest) => Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            // Navigate to class test detail page
                            print('Class test tapped: ${classTest.id}');
                          },
                          child: ClassTestCard(
                            title: classTest.title,
                            description: classTest.description,
                            date: classTest.date,
                            iconText: classTest.iconText,
                            duration: classTest.duration,
                            totalMarks: classTest.totalMarks,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  )
                      .toList(),
                ),
              const SizedBox(height: 12), // Reduced height
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  side: const BorderSide(color: Colors.orange), // Orange border
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 12), // Increased width
                ),
                onPressed: onCreateClassTest,
                child: const Text(
                  '+ Create Class Test',
                  style: TextStyle(color: Colors.orange), // Orange text color
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}