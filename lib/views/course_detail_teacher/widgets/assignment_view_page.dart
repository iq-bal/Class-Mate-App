import 'package:flutter/material.dart';

class AssignmentViewPage extends StatelessWidget {
  final String assignmentId;

  const AssignmentViewPage({super.key, required this.assignmentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignment Details'),
      ),
      body: Center(
        child: Text(
          'Assignment ID: $assignmentId',
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
