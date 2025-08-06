import 'package:flutter/material.dart';
import 'package:classmate/controllers/notification/notification_controller.dart';
import 'package:classmate/models/notification/notification_model.dart';
import 'package:classmate/views/notification/widgets/notification_item.dart';
import 'package:classmate/views/notification/widgets/notification_filters.dart';

class NotificationListView extends StatefulWidget {
  const NotificationListView({super.key});

  @override
  State<NotificationListView> createState() => _NotificationListViewState();
}

class _NotificationListViewState extends State<NotificationListView> {
  final NotificationController _controller = NotificationController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.initialize();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      _controller.loadMoreNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[800],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              switch (value) {
                case 'mark_all_read':
                  _controller.markAllNotificationsAsRead();
                  break;
                case 'delete_read':
                  _showDeleteReadConfirmation();
                  break;
                case 'refresh':
                  _controller.refreshNotifications();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mark_all_read',
                child: Row(
                  children: [
                    Icon(Icons.mark_email_read, size: 20),
                    SizedBox(width: 8),
                    Text('Mark all as read'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete_read',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep, size: 20),
                    SizedBox(width: 8),
                    Text('Delete read'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh, size: 20),
                    SizedBox(width: 8),
                    Text('Refresh'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Column(
            children: [
              // Filters
              NotificationFilters(
                onTypeChanged: (type) {
                  final newFilter = Map<String, dynamic>.from(_controller.currentFilter);
                  newFilter['type'] = type;
                  _controller.applyFilter(newFilter);
                },
                onReadStatusChanged: (status) {
                  final newFilter = Map<String, dynamic>.from(_controller.currentFilter);
                  newFilter['readStatus'] = status;
                  _controller.applyFilter(newFilter);
                },
                onPriorityChanged: (priority) {
                  final newFilter = Map<String, dynamic>.from(_controller.currentFilter);
                  newFilter['priority'] = priority;
                  _controller.applyFilter(newFilter);
                },
                onClearFilters: () {
                  _controller.clearFilters();
                },
              ),
              
              // Notification List
              Expanded(
                child: _buildNotificationList(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNotificationList() {
    switch (_controller.state) {
      case NotificationState.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );
      
      case NotificationState.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading notifications',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _controller.errorMessage ?? 'Unknown error occurred',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _controller.refreshNotifications(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      
      case NotificationState.loaded:
        if (_controller.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_none,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No notifications yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You\'ll see notifications here when you receive them',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        
        return RefreshIndicator(
          onRefresh: _controller.refreshNotifications,
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _controller.notifications.length + 
                (_controller.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _controller.notifications.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              
              final notification = _controller.notifications[index];
              return NotificationItem(
                notification: notification,
                onTap: () => _controller.handleNotificationClick(notification),
                onDelete: () => _showDeleteConfirmation(notification),
              );
            },
          ),
        );
      
      default:
        return const SizedBox.shrink();
    }
  }

  void _showDeleteConfirmation(NotificationModel notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Notification'),
        content: const Text('Are you sure you want to delete this notification?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _controller.deleteNotification(notification.id);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showDeleteReadConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Read Notifications'),
        content: const Text('Are you sure you want to delete all read notifications?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _controller.deleteAllReadNotifications();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}