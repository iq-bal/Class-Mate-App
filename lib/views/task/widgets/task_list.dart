import 'package:classmate/controllers/task/task_controller.dart';
import 'package:classmate/views/task/widgets/task_card.dart';
import 'package:flutter/material.dart';

class TaskList extends StatelessWidget {
  final TaskController taskController;

  const TaskList({super.key, required this.taskController});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/background.jpg',
            fit: BoxFit.cover,
          ),
        ),
        ListView.builder(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
          itemCount: 4,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: TaskCard(index: index),
            );
          },
        ),
      ],
    );
  }
}
