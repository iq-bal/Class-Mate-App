import 'package:flutter/foundation.dart';
import 'package:classmate/models/notification/notification_model.dart';
import 'package:classmate/services/notification/stored_notification_service.dart';

enum NotificationState {
  initial,
  loading,
  loaded,
  error,
}

class NotificationController extends ChangeNotifier {
  final StoredNotificationService _notificationService = StoredNotificationService();

  // State management
  NotificationState _state = NotificationState.initial;
  String? _errorMessage;
  
  // Notification data
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  NotificationStats? _stats;
  
  // Pagination
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasNextPage = false;
  bool _hasPrevPage = false;
  final int _limit = 20;
  
  // Filters
  Map<String, dynamic> _currentFilter = {};
  
  // Loading states
  bool _isLoadingMore = false;
  bool _isRefreshing = false;

  // Getters
  NotificationState get state => _state;
  String? get errorMessage => _errorMessage;
  List<NotificationModel> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _unreadCount;
  NotificationStats? get stats => _stats;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get hasNextPage => _hasNextPage;
  bool get hasPrevPage => _hasPrevPage;
  Map<String, dynamic> get currentFilter => Map.from(_currentFilter);
  bool get isLoadingMore => _isLoadingMore;
  bool get isRefreshing => _isRefreshing;

  // Initialize and fetch notifications
  Future<void> initialize() async {
    await fetchNotifications(refresh: true);
    await fetchUnreadCount();
  }

  // Fetch notifications with pagination
  Future<void> fetchNotifications({
    bool refresh = false,
    Map<String, dynamic>? filter,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _notifications.clear();
      _isRefreshing = true;
    } else {
      _isLoadingMore = true;
    }

    if (filter != null) {
      _currentFilter = filter;
    }

    _setState(refresh ? NotificationState.loading : _state);

    try {
      final result = await _notificationService.getNotifications(
        page: _currentPage,
        limit: _limit,
        type: _currentFilter['type'] != null ? NotificationType.values.firstWhere(
          (e) => e.toString().split('.').last == _currentFilter['type'],
          orElse: () => NotificationType.announcement,
        ) : null,
        isRead: _currentFilter['readStatus'],
        priority: _currentFilter['priority'] != null ? NotificationPriority.values.firstWhere(
          (e) => e.toString().split('.').last == _currentFilter['priority'],
          orElse: () => NotificationPriority.normal,
        ) : null,
      );

      if (result != null) {
        if (refresh) {
          _notifications = result.notifications;
        } else {
          _notifications.addAll(result.notifications);
        }

        _totalPages = result.totalPages;
        _hasNextPage = result.hasNextPage;
        _hasPrevPage = result.hasPrevPage;
      }

      _setState(NotificationState.loaded);
    } catch (e) {
      _errorMessage = e.toString();
      _setState(NotificationState.error);
    } finally {
      _isLoadingMore = false;
      _isRefreshing = false;
    }
  }

  // Load more notifications (pagination)
  Future<void> loadMoreNotifications() async {
    if (_hasNextPage && !_isLoadingMore) {
      _currentPage++;
      await fetchNotifications();
    }
  }

  // Refresh notifications
  Future<void> refreshNotifications() async {
    await fetchNotifications(refresh: true);
    await fetchUnreadCount();
  }

  // Apply filters
  Future<void> applyFilter(Map<String, dynamic> filter) async {
    await fetchNotifications(refresh: true, filter: filter);
  }

  // Clear filters
  Future<void> clearFilters() async {
    _currentFilter.clear();
    await fetchNotifications(refresh: true);
  }

  // Fetch unread count
  Future<void> fetchUnreadCount() async {
    try {
      _unreadCount = await _notificationService.getUnreadNotificationCount();
      notifyListeners();
    } catch (e) {
      print('Error fetching unread count: $e');
    }
  }

  // Fetch notification stats
  Future<void> fetchNotificationStats() async {
    try {
      _stats = await _notificationService.getNotificationStats();
      notifyListeners();
    } catch (e) {
      print('Error fetching notification stats: $e');
    }
  }

  // Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _notificationService.markNotificationAsRead(notificationId);
      
      // Update local state
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        final notification = _notifications[index];
        if (!notification.isRead) {
          _notifications[index] = NotificationModel(
            id: notification.id,
            title: notification.title,
            body: notification.body,
            type: notification.type,
            recipientId: notification.recipientId,
            senderId: notification.senderId,
            relatedEntityId: notification.relatedEntityId,
            relatedEntityType: notification.relatedEntityType,
            data: notification.data,
            isRead: true,
            readAt: DateTime.now(),
            clickAction: notification.clickAction,
            priority: notification.priority,
            fcmSent: notification.fcmSent,
            fcmSentAt: notification.fcmSentAt,
            createdAt: notification.createdAt,
            updatedAt: DateTime.now(),
          );
          
          _unreadCount = (_unreadCount - 1).clamp(0, double.infinity).toInt();
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  // Mark multiple notifications as read
  Future<void> markNotificationsAsRead(List<String> notificationIds) async {
    try {
      await _notificationService.markNotificationsAsRead(notificationIds);
      
      // Update local state
      int markedCount = 0;
      for (int i = 0; i < _notifications.length; i++) {
        if (notificationIds.contains(_notifications[i].id) && !_notifications[i].isRead) {
          final notification = _notifications[i];
          _notifications[i] = NotificationModel(
            id: notification.id,
            title: notification.title,
            body: notification.body,
            type: notification.type,
            recipientId: notification.recipientId,
            senderId: notification.senderId,
            relatedEntityId: notification.relatedEntityId,
            relatedEntityType: notification.relatedEntityType,
            data: notification.data,
            isRead: true,
            readAt: DateTime.now(),
            clickAction: notification.clickAction,
            priority: notification.priority,
            fcmSent: notification.fcmSent,
            fcmSentAt: notification.fcmSentAt,
            createdAt: notification.createdAt,
            updatedAt: DateTime.now(),
          );
          markedCount++;
        }
      }
      
      _unreadCount = (_unreadCount - markedCount).clamp(0, double.infinity).toInt();
      notifyListeners();
    } catch (e) {
      print('Error marking notifications as read: $e');
    }
  }

  // Mark all notifications as read
  Future<void> markAllNotificationsAsRead() async {
    try {
      await _notificationService.markAllNotificationsAsRead();
      
      // Update local state
      for (int i = 0; i < _notifications.length; i++) {
        if (!_notifications[i].isRead) {
          final notification = _notifications[i];
          _notifications[i] = NotificationModel(
            id: notification.id,
            title: notification.title,
            body: notification.body,
            type: notification.type,
            recipientId: notification.recipientId,
            senderId: notification.senderId,
            relatedEntityId: notification.relatedEntityId,
            relatedEntityType: notification.relatedEntityType,
            data: notification.data,
            isRead: true,
            readAt: DateTime.now(),
            clickAction: notification.clickAction,
            priority: notification.priority,
            fcmSent: notification.fcmSent,
            fcmSentAt: notification.fcmSentAt,
            createdAt: notification.createdAt,
            updatedAt: DateTime.now(),
          );
        }
      }
      
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      final success = await _notificationService.deleteNotification(notificationId);
      if (success) {
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          final notification = _notifications[index];
          _notifications.removeAt(index);
          
          if (!notification.isRead) {
            _unreadCount = (_unreadCount - 1).clamp(0, double.infinity).toInt();
          }
          
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  // Delete all read notifications
  Future<void> deleteAllReadNotifications() async {
    try {
      await _notificationService.deleteAllReadNotifications();
      
      // Update local state
      _notifications.removeWhere((notification) => notification.isRead);
      notifyListeners();
    } catch (e) {
      print('Error deleting read notifications: $e');
    }
  }

  // Handle notification click action
  void handleNotificationClick(NotificationModel notification) {
    // Mark as read if not already read
    if (!notification.isRead) {
      markNotificationAsRead(notification.id);
    }
    
    // Handle click action based on notification type and click_action
    // This will be implemented based on your app's navigation structure
    _handleClickAction(notification);
  }

  void _handleClickAction(NotificationModel notification) {
    // TODO: Implement navigation based on click_action
    // This should be customized based on your app's routing
    switch (notification.clickAction) {
      case 'TASK_DETAIL':
        // Navigate to task detail page
        print('Navigate to task: ${notification.data?['taskId']}');
        break;
      case 'COURSE_SCHEDULE_UPDATE':
        // Navigate to course schedule
        print('Navigate to course schedule: ${notification.data?['courseId']}');
        break;
      case 'ASSIGNMENT_DETAIL':
        // Navigate to assignment
        print('Navigate to assignment: ${notification.data?['assignmentId']}');
        break;
      default:
        // Default action or no action
        print('No specific action for: ${notification.clickAction}');
        break;
    }
  }

  void _setState(NotificationState newState) {
    _state = newState;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}