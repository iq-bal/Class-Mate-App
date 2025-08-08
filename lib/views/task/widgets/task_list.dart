import 'package:classmate/controllers/task/task_controller.dart';
import 'package:classmate/views/task/widgets/subtle_grid_background.dart';
import 'package:classmate/views/task/widgets/task_card.dart';
import 'package:flutter/material.dart';

class TaskList extends StatelessWidget {
  final TaskController taskController;

  const TaskList({super.key, required this.taskController});

  @override
  Widget build(BuildContext context) {
    return SubtleGridBackground(
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        itemCount: taskController.tasks?.length ?? 0,
        itemBuilder: (context, index) {
          final task = taskController.tasks![index];
          return TaskCard(
            task: task,
            index: index,
          );
        },
      ),
    );
  }
}
