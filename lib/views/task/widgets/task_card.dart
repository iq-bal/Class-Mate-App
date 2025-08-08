import 'package:flutter/material.dart';
import 'package:classmate/models/task/task_model.dart';
import 'package:classmate/views/task/widgets/edit_task_bottom_sheet.dart';
import 'package:classmate/controllers/task/task_controller.dart';
import 'package:classmate/config/app_config.dart';
import 'package:intl/intl.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final int index;
  final TaskController taskController = TaskController();

  TaskCard({
    super.key,
    required this.task,
    required this.index,
  });
  
  void _showEditTaskBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditTaskBottomSheet(task: task),
    );
  }
  
  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: Text('Are you sure you want to delete "${task.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // Show loading indicator
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Deleting task...')),
                );
                
                try {
                  await taskController.deleteTask(task.id!);
                  
                  // Show success message
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Task deleted successfully')),
                    );
                  }
                } catch (e) {
                  // Show error message
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to delete task: $e')),
                    );
                  }
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.blue.shade400,
      Colors.green.shade400,
      Colors.orange.shade400,
      Colors.purple.shade400,
      Colors.cyan.shade400,
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vertical timeline with start and end times
          Column(
            children: [
              // Start time
              Text(
                task.startTime ?? "00:00",
                style: TextStyle(
                  color: Colors.blue[900],
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              // Timeline indicator
              Column(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: colors[index % colors.length],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: colors[index % colors.length].withValues(alpha: 0.5),
                          spreadRadius: 2,
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 2,
                    height: 100, // Adjust this height to fit your design
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          colors[index % colors.length],
                          Colors.grey[200]!,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // End time
              Text(
                task.endTime ?? "00:00",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Task Card with Left Border
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border(
                  left: BorderSide(
                    color: colors[index % colors.length],
                    width: 10, // Increased left border width
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.2),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Category Tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: colors[index % colors.length].withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          task.category?.toUpperCase() ?? 'NO CATEGORY',
                          style: TextStyle(
                            color: colors[index % colors.length],
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      // Menu
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                        elevation: 2,
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showEditTaskBottomSheet(context);
                          } else if (value == 'delete') {
                            _showDeleteConfirmationDialog(context);
                          }
                        },
                        itemBuilder: (BuildContext context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit Task'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete Task', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Title
                  Text(
                    task.title ?? 'Untitled Task',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Participants and Date Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Date
                      if (task.date != null)
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: colors[index % colors.length],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              DateFormat('EEE, MMM dd, yyyy')
                                  .format(task.date!),
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 15,
                                fontWeight: FontWeight.w600, // Make it bold
                              ),
                            ),
                          ],
                        ),
                      // Participants
                      if (task.participants != null &&
                          task.participants!.isNotEmpty)
                        Row(
                          children: [
                            for (var i = 0;
                            i < task.participants!.length.clamp(0, 4);
                            i++)
                              Padding(
                                padding: const EdgeInsets.only(left: 4.0),
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundImage: task.participants![i]
                                      .profilePicture !=
                                      null
                                      ? NetworkImage(
                                          task.participants![i].profilePicture!.startsWith('http')
                                              ? task.participants![i].profilePicture!
                                              : '${AppConfig.imageServer}${task.participants![i].profilePicture!}'
                                      )
                                      : const AssetImage(
                                      'assets/images/avatar.png')
                                  as ImageProvider,
                                ),
                              ),
                            if (task.participants!.length > 4)
                              Padding(
                                padding: const EdgeInsets.only(left: 4.0),
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.grey.shade300,
                                  child: Text(
                                    '+${task.participants!.length - 4}',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
