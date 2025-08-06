import 'package:classmate/models/notification/notification_model.dart';
import 'package:classmate/core/dio_client.dart';
import 'package:classmate/config/app_config.dart';

class StoredNotificationService {
  final DioClient _dioClient = DioClient();

  // GraphQL Queries
  static const String _getNotificationsQuery = '''
    query GetNotifications(\$page: Int, \$limit: Int, \$filter: NotificationFilterInput) {
      notifications(page: \$page, limit: \$limit, filter: \$filter) {
        notifications {
          id
          title
          body
          type
          recipient_id {
            id
            name
          }
          sender_id {
            id
            name
          }
          related_entity_id
          related_entity_type
          data
          is_read
          read_at
          click_action
          priority
          createdAt
          updatedAt
        }
        total
        page
        limit
        totalPages
        hasNextPage
        hasPrevPage
      }
    }
  ''';

  static const String _getUnreadCountQuery = '''
    query GetUnreadNotificationCount {
      getUnreadNotificationCount
    }
  ''';

  static const String _getNotificationStatsQuery = '''
    query GetNotificationStats {
      getNotificationStats {
        total
        unread
        read
        byType {
          type
          count
        }
      }
    }
  ''';

  static const String _getNotificationQuery = '''
    query GetNotification(\$id: ID!) {
      getNotification(id: \$id) {
        _id
        title
        body
        type
        recipient_id {
          _id
          name
          email
        }
        sender_id {
          _id
          name
          email
        }
        related_entity_id
        related_entity_type
        data
        is_read
        read_at
        click_action
        priority
        fcm_sent
        fcm_sent_at
        created_at
        updated_at
      }
    }
  ''';

  // GraphQL Mutations
  static const String _markAsReadMutation = '''
    mutation MarkNotificationAsRead(\$id: ID!) {
      markNotificationAsRead(id: \$id) {
        _id
        is_read
        read_at
      }
    }
  ''';

  static const String _markMultipleAsReadMutation = '''
    mutation MarkNotificationsAsRead(\$ids: [ID!]!) {
      markNotificationsAsRead(ids: \$ids) {
        _id
        is_read
        read_at
      }
    }
  ''';

  static const String _markAllAsReadMutation = '''
    mutation MarkAllNotificationsAsRead {
      markAllNotificationsAsRead
    }
  ''';

  static const String _deleteNotificationMutation = '''
    mutation DeleteNotification(\$id: ID!) {
      deleteNotification(id: \$id)
    }
  ''';

  static const String _deleteAllReadMutation = '''
    mutation DeleteAllReadNotifications {
      deleteAllReadNotifications
    }
  ''';

  // Service Methods
  Future<PaginatedNotifications?> getNotifications({
    int page = 1,
    int limit = 20,
    NotificationType? type,
    bool? isRead,
    NotificationPriority? priority,
  }) async {
    try {
      final response = await _dioClient.getDio(AppConfig.graphqlServer).post(
        '/',
        data: {
          'query': _getNotificationsQuery,
          'variables': {
            'page': page,
            'limit': limit,
            'filter': {
              if (type != null) 'type': type.toString().split('.').last,
              if (isRead != null) 'is_read': isRead,
              if (priority != null) 'priority': priority.toString().split('.').last,
            },
          },
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['errors'] != null) {
          print('GraphQL Error: ${data['errors']}');
          return null;
        }

        if (data['data'] != null && data['data']['notifications'] != null) {
          return PaginatedNotifications.fromJson(data['data']['notifications']);
        }
      }

      return null;
    } catch (e) {
      print('Error fetching notifications: $e');
      return null;
    }
  }

  Future<int> getUnreadNotificationCount() async {
    try {
      final response = await _dioClient.getDio(AppConfig.graphqlServer).post(
        '/',
        data: {
          'query': _getUnreadCountQuery,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['errors'] != null) {
          print('GraphQL Error: ${data['errors']}');
          return 0;
        }

        return data['data']['getUnreadNotificationCount'] ?? 0;
      }

      return 0;
    } catch (e) {
      print('Error fetching unread count: $e');
      return 0;
    }
  }

  Future<NotificationStats?> getNotificationStats() async {
    try {
      final response = await _dioClient.getDio(AppConfig.graphqlServer).post(
        '/',
        data: {
          'query': _getNotificationStatsQuery,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['errors'] != null) {
          print('GraphQL Error: ${data['errors']}');
          return null;
        }

        return NotificationStats.fromJson(data['data']['getNotificationStats']);
      }

      return null;
    } catch (e) {
      print('Error fetching notification stats: $e');
      return null;
    }
  }

  Future<NotificationModel?> getNotification(String id) async {
    try {
      final response = await _dioClient.getDio(AppConfig.graphqlServer).post(
        '/',
        data: {
          'query': _getNotificationQuery,
          'variables': {'id': id},
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['errors'] != null) {
          print('GraphQL Error: ${data['errors']}');
          return null;
        }

        final notificationData = data['data']['getNotification'];
        if (notificationData == null) return null;

        return NotificationModel.fromJson(notificationData);
      }

      return null;
    } catch (e) {
      print('Error fetching notification: $e');
      return null;
    }
  }

  Future<NotificationModel?> markNotificationAsRead(String id) async {
    try {
      final response = await _dioClient.getDio(AppConfig.graphqlServer).post(
        '/',
        data: {
          'query': _markAsReadMutation,
          'variables': {'id': id},
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['errors'] != null) {
          print('GraphQL Error: ${data['errors']}');
          return null;
        }

        return NotificationModel.fromJson(data['data']['markNotificationAsRead']);
      }

      return null;
    } catch (e) {
      print('Error marking notification as read: $e');
      return null;
    }
  }

  Future<List<NotificationModel>?> markNotificationsAsRead(List<String> ids) async {
    try {
      final response = await _dioClient.getDio(AppConfig.graphqlServer).post(
        '/',
        data: {
          'query': _markMultipleAsReadMutation,
          'variables': {'ids': ids},
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['errors'] != null) {
          print('GraphQL Error: ${data['errors']}');
          return null;
        }

        return (data['data']['markNotificationsAsRead'] as List)
            .map((item) => NotificationModel.fromJson(item))
            .toList();
      }

      return null;
    } catch (e) {
      print('Error marking notifications as read: $e');
      return null;
    }
  }

  Future<int> markAllNotificationsAsRead() async {
    try {
      final response = await _dioClient.getDio(AppConfig.graphqlServer).post(
        '/',
        data: {
          'query': _markAllAsReadMutation,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['errors'] != null) {
          print('GraphQL Error: ${data['errors']}');
          return 0;
        }

        return data['data']['markAllNotificationsAsRead'] ?? 0;
      }

      return 0;
    } catch (e) {
      print('Error marking all notifications as read: $e');
      return 0;
    }
  }

  Future<bool> deleteNotification(String id) async {
    try {
      final response = await _dioClient.getDio(AppConfig.graphqlServer).post(
        '/',
        data: {
          'query': _deleteNotificationMutation,
          'variables': {'id': id},
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['errors'] != null) {
          print('GraphQL Error: ${data['errors']}');
          return false;
        }

        return data['data']['deleteNotification'] ?? false;
      }

      return false;
    } catch (e) {
      print('Error deleting notification: $e');
      return false;
    }
  }

  Future<int> deleteAllReadNotifications() async {
    try {
      final response = await _dioClient.getDio(AppConfig.graphqlServer).post(
        '/',
        data: {
          'query': _deleteAllReadMutation,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['errors'] != null) {
          print('GraphQL Error: ${data['errors']}');
          return 0;
        }

        return data['data']['deleteAllReadNotifications'] ?? 0;
      }

      return 0;
    } catch (e) {
      print('Error deleting read notifications: $e');
      return 0;
    }
  }
}