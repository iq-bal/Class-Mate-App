import 'package:classmate/controllers/task/task_controller.dart';
import 'package:classmate/views/task/create_task_view.dart';
import 'package:classmate/views/task/widgets/date_scroll.dart';
import 'package:classmate/views/task/widgets/task_header.dart';
import 'package:classmate/views/task/widgets/task_list.dart';
import 'package:flutter/material.dart';

class TaskView extends StatefulWidget {
  const TaskView({super.key});
  @override
  State<TaskView> createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> {
  final TaskController taskController = TaskController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    await taskController.getTasks();
    setState(() {}); // Trigger a rebuild to reflect the loaded tasks
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TaskHeader(), // Header with date and task summary
          const DateScroll(), // Horizontal scroll for dates
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: taskController.stateNotifier,
              builder: (context, state, child) {
                if (state == TaskState.loading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state == TaskState.error) {
                  return Center(
                    child: Text(
                      taskController.errorMessage ?? 'Error loading tasks.',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                } else if (taskController.tasks == null || taskController.tasks!.isEmpty) {
                  return const Center(child: Text('No tasks available.'));
                } else {
                  return TaskList(taskController: taskController);
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateTaskView())
          );
        },
        backgroundColor: Colors.blue[900],
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
