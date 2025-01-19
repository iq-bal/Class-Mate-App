import 'package:flutter/material.dart';

class TaskInvitationDialog extends StatelessWidget {
  final String taskId;
  final String taskTitle;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const TaskInvitationDialog({
    required this.taskId,
    required this.taskTitle,
    required this.onAccept,
    required this.onDecline,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Task Invitation'),
      content: Text('You have been invited to task: $taskTitle'),
      actions: [
        TextButton(
          onPressed: onAccept,
          style: TextButton.styleFrom(
            foregroundColor: Colors.green,
          ),
          child: const Text('Accept'),
        ),
        TextButton(
          onPressed: onDecline,
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
          ),
          child: const Text('Decline'),
        ),
      ],
    );
  }
}