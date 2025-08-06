import 'package:flutter/material.dart';
import 'package:classmate/models/notification/notification_model.dart';

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const NotificationItem({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.white : Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.isRead ? Colors.grey[200]! : Colors.blue[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notification Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getNotificationColor(notification.type),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  _getNotificationIcon(notification.type),
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              
              // Notification Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Priority
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: notification.isRead 
                                  ? FontWeight.w500 
                                  : FontWeight.w700,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (notification.priority == NotificationPriority.urgent ||
                            notification.priority == NotificationPriority.high)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: notification.priority == NotificationPriority.urgent
                                  ? Colors.red[100]
                                  : Colors.orange[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              notification.priority.toString().split('.').last.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: notification.priority == NotificationPriority.urgent
                                    ? Colors.red[800]
                                    : Colors.orange[800],
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    
                    // Body
                    Text(
                      notification.body,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    
                    // Metadata
                    Row(
                      children: [
                        // Sender info
                        if (notification.senderId != null) ...[
                          Icon(
                            Icons.person,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            notification.senderId!.name,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        
                        // Time
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatTimeAgo(notification.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        
                        const Spacer(),
                        
                        // Unread indicator
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.blue[600],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Delete button
              IconButton(
                onPressed: onDelete,
                icon: Icon(
                  Icons.delete_outline,
                  color: Colors.grey[400],
                  size: 20,
                ),
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.taskAssigned:
      case NotificationType.taskUpdated:
        return Icons.assignment;
      case NotificationType.taskDueReminder:
        return Icons.schedule;
      case NotificationType.courseReschedule:
        return Icons.event;
      case NotificationType.assignmentGraded:
        return Icons.grade;
      case NotificationType.classCancelled:
        return Icons.cancel;
      case NotificationType.announcement:
        return Icons.campaign;
      case NotificationType.systemUpdate:
        return Icons.system_update;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.taskAssigned:
      case NotificationType.taskUpdated:
        return Colors.blue[600]!;
      case NotificationType.taskDueReminder:
        return Colors.orange[600]!;
      case NotificationType.courseReschedule:
        return Colors.purple[600]!;
      case NotificationType.assignmentGraded:
        return Colors.green[600]!;
      case NotificationType.classCancelled:
        return Colors.red[600]!;
      case NotificationType.announcement:
        return Colors.indigo[600]!;
      case NotificationType.systemUpdate:
        return Colors.grey[600]!;
      default:
        return Colors.blue[600]!;
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}