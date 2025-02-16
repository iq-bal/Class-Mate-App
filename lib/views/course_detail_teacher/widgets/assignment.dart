import 'package:classmate/views/course_detail_teacher/widgets/assignment_view_page.dart';
import 'package:flutter/material.dart';
import 'package:classmate/views/course_detail_teacher/widgets/assignment_card.dart';
import 'package:classmate/views/course_detail_teacher/widgets/not_found.dart';

class Assignment {
  final String id;
  final String title;
  final String description;
  final String dueDate;
  final String iconText;
  final int totalItems;

  Assignment({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.iconText,
    required this.totalItems,
  });
}

class AssignmentContainer extends StatelessWidget {
  final List<Assignment> assignments;
  final VoidCallback onCreateAssignment;

  const AssignmentContainer({
    super.key,
    required this.assignments,
    required this.onCreateAssignment,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Aligns text and container to the left
      children: [
        const Text(
          'Active Assignment',
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
              if (assignments.isEmpty)
                const NotFoundWidget(
                  emoji: '🤔',
                  title: 'Assignment Not Found',
                  subtitle: 'You don\'t have active assignments',
                )
              else
                Column(
                  children: assignments
                      .map(
                        (assignment) => Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AssignmentViewPage(assignmentId: assignment.id),
                              ),
                            );
                          },
                          child: AssignmentCard(
                            title: assignment.title,
                            description: assignment.description,
                            dueDate: assignment.dueDate,
                            iconText: assignment.iconText,
                            totalItems: assignment.totalItems,
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
                  side: const BorderSide(color: Colors.teal), // Teal border
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 12), // Increased width
                ),
                onPressed: onCreateAssignment,
                child: const Text(
                  '+ Create Assignment',
                  style: TextStyle(color: Colors.teal), // Teal text color
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
