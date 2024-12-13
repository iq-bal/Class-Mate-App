import 'package:flutter/material.dart';

/// A reusable component to display a single student's information.
class StudentTile extends StatelessWidget {
  final String name;
  final String id;
  final bool isPresent;

  const StudentTile({
    Key? key,
    required this.name,
    required this.id,
    required this.isPresent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD9D9D9)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.grey,
          child: Icon(Icons.person),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(id),
        trailing: Icon(
          isPresent ? Icons.check_circle : Icons.error,
          color: isPresent ? Colors.green : Colors.red,
        ),
      ),
    );
  }
}

/// A reusable component to display a list of students.
class StudentList extends StatelessWidget {
  final List<Map<String, dynamic>> students; // List of student data
  final String title;
  final bool showViewAll;
  final VoidCallback? onViewAllPressed;

  const StudentList({
    Key? key,
    required this.students,
    this.title = 'Student List',
    this.showViewAll = false,
    this.onViewAllPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            if (showViewAll)
              GestureDetector(
                onTap: onViewAllPressed,
                child: const Text(
                  'View All',
                  style: TextStyle(color: Colors.blue, fontSize: 14),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: students.length,
          itemBuilder: (context, index) {
            final student = students[index];
            return StudentTile(
              name: student['name'],
              id: student['id'],
              isPresent: student['isPresent'],
            );
          },
        ),
      ],
    );
  }
}
