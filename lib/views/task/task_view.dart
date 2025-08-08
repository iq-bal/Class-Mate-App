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


  DateTime selectedDate = DateTime.now();


  @override
  void initState() {
    super.initState();
    _loadTasksForDate(selectedDate); // Load today's tasks by default
  }

  Future<void> _loadTasksForDate(DateTime date) async {
    await taskController.getTasksByDate(date);
    setState(() {}); // Trigger a rebuild to reflect the loaded tasks
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      selectedDate = date;
    });
    _loadTasksForDate(date); // Load tasks for the selected date
  }

  Future<void> _refreshTasks() async {
    await _loadTasksForDate(selectedDate);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TaskHeader(), // Header with date and task summary
          DateScroll(
            selectedDate: selectedDate,
            onDateSelected: _onDateSelected,
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _refreshTasks(),
              child: ValueListenableBuilder(
                valueListenable: taskController.stateNotifier,
                builder: (context, state, child) {
                  if (state == TaskState.loading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state == TaskState.error) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                taskController.errorMessage ?? 'Error loading tasks.',
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => _refreshTasks(),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  } else if (taskController.tasks == null || taskController.tasks!.isEmpty) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.task_alt,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No tasks for ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Pull down to refresh or create a new task',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  } else {
                    return TaskList(taskController: taskController);
                  }
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateTaskView())
          );
          // If task was created successfully, refresh the current tasks
          if (result == true) {
            await _refreshTasks();
          }
        },
        backgroundColor: Colors.blue[900],
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
