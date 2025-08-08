import 'package:classmate/models/task/task_model.dart';
import 'package:classmate/models/task/user_model.dart';
import 'package:classmate/services/task/task_services.dart';
import 'package:flutter/material.dart';

enum TaskState { idle, loading, success, error }
class TaskController {
  final TaskService _taskService = TaskService();
  final ValueNotifier<TaskState> stateNotifier = ValueNotifier<TaskState>(TaskState.idle);
  String? errorMessage;
  List<TaskModel>? tasks;
  List<UserModel>? users;


  Future<void> getUsers() async {
    stateNotifier.value = TaskState.loading;
    errorMessage = '';
    try {
      users = await _taskService.getUsers();
      stateNotifier.value = TaskState.success;
    } catch (e) {
      errorMessage = 'Failed to get users: $e';
      stateNotifier.value = TaskState.error;
    }
  } 

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

  Future<void> getTasksByDate(DateTime date) async {
    stateNotifier.value = TaskState.loading;
    errorMessage = '';
    try {
      // Format date as YYYY-MM-DD
      final formattedDate = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      tasks = await _taskService.getTasksByDate(formattedDate);
      stateNotifier.value = TaskState.success;
    } catch (e) {
      errorMessage = 'Failed to get tasks by date: $e';
      stateNotifier.value = TaskState.error;
    }
  }

  Future<void> createTask(TaskModel task) async {
    stateNotifier.value = TaskState.loading;
    errorMessage = '';
    try {
      await _taskService.createTask(task);
      stateNotifier.value = TaskState.success;
    } catch (e) {
      print("Error creating task: $e");
      errorMessage = 'Failed to create task: $e';
      stateNotifier.value = TaskState.error;
    }
  }
  
  Future<void> updateTask(String id, TaskModel task) async {
    stateNotifier.value = TaskState.loading;
    errorMessage = '';
    try {
      await _taskService.updateTask(id, task);
      await getTasks(); // Refresh tasks after update
      stateNotifier.value = TaskState.success;
    } catch (e) {
      print("Error updating task: $e");
      errorMessage = 'Failed to update task: $e';
      stateNotifier.value = TaskState.error;
    }
  }

  Future<void> deleteTask(String id) async {
    stateNotifier.value = TaskState.loading;
    errorMessage = '';
    try {
      await _taskService.deleteTask(id);
      await getTasks(); // Refresh tasks after deletion
      stateNotifier.value = TaskState.success;
    } catch (e) {
      print("Error deleting task: $e");
      errorMessage = 'Failed to delete task: $e';
      stateNotifier.value = TaskState.error;
    }
  }

}
