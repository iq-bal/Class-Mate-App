import 'package:classmate/services/task/task_services.dart';
import 'package:classmate/views/task_invitation_dialog.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class TaskNotificationHandler {
  final TaskService taskService;
  final BuildContext context;

  TaskNotificationHandler({
    required this.taskService,
    required this.context,
  });

  void handleTaskNotification(RemoteMessage message) {
    if (message.data['type'] == 'task_invitation') {
      showDialog(
        context: context,
        builder: (context) => TaskInvitationDialog(
          taskId: message.data['taskId'],
          taskTitle: message.notification?.title ?? 'New Task',
          onAccept: () => _handleResponse(message.data['taskId'], 'accepted'),
          onDecline: () => _handleResponse(message.data['taskId'], 'declined'),
        ),
      );
    }
  }

  Future<void> _handleResponse(String taskId, String response) async {
    try {
      await taskService.respondToInvitation(taskId, response);
      if (context.mounted) {
        Navigator.of(context).pop(); // Close the dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully ${response} the task invitation'),
            backgroundColor: response == 'accepted' ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to respond to invitation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}