import 'package:classmate/services/task/task_service.dart';
import 'package:flutter/material.dart';

enum TaskState { idle, loading, success, error }
class TaskController {
  final TaskService _taskService = TaskService();
  final ValueNotifier<TaskState> stateNotifier = ValueNotifier<TaskState>(TaskState.idle);
  String? errorMessage;
  List<TaskEntity>? tasks;

  Future<void> getTasks() async {
    stateNotifier.value = TaskState.loading;
    errorMessage = '';
    try {
      tasks = await _taskService.getTasks();
      stateNotifier.value = TaskState.success;
    } catch (e) {
      errorMessage = 'Failed to get tasks: $e';
      stateNotifier.value = TaskState.error;
    }
  }

  Future<void> createTask(TaskEntity task) async {
    stateNotifier.value = TaskState.loading;
    errorMessage = '';
    try {
      await _taskService.createTask(task);
      stateNotifier.value = TaskState.success;
    } catch (e) {
      errorMessage = 'Failed to create task: $e';
      stateNotifier.value = TaskState.error;
    }
  }
}
