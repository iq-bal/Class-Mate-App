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

  Future<void> createTask(TaskModel task) async {
    stateNotifier.value = TaskState.loading;
    errorMessage = '';
    try {
      print("Creating task with payload: ${task.toJson()}");
      await _taskService.createTask(task);
      stateNotifier.value = TaskState.success;
    } catch (e) {
      print("Error creating task: $e");
      errorMessage = 'Failed to create task: $e';
      stateNotifier.value = TaskState.error;
    }
  }


}
