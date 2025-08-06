class NotificationModel {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final UserModel recipientId;
  final UserModel? senderId;
  final String? relatedEntityId;
  final RelatedEntityType? relatedEntityType;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime? readAt;
  final String? clickAction;
  final NotificationPriority priority;
  final bool fcmSent;
  final DateTime? fcmSentAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.recipientId,
    this.senderId,
    this.relatedEntityId,
    this.relatedEntityType,
    this.data,
    required this.isRead,
    this.readAt,
    this.clickAction,
    required this.priority,
    required this.fcmSent,
    this.fcmSentAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? json['_id'],
      title: json['title'],
      body: json['body'],
      type: NotificationType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => NotificationType.announcement,
      ),
      recipientId: UserModel.fromJson(json['recipient_id']),
      senderId: json['sender_id'] != null ? UserModel.fromJson(json['sender_id']) : null,
      relatedEntityId: json['related_entity_id'],
      relatedEntityType: json['related_entity_type'] != null
          ? RelatedEntityType.values.firstWhere(
              (e) => e.toString().split('.').last == json['related_entity_type'],
              orElse: () => RelatedEntityType.other,
            )
          : null,
      data: json['data'],
      isRead: json['is_read'] ?? false,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      clickAction: json['click_action'],
      priority: NotificationPriority.values.firstWhere(
        (e) => e.toString().split('.').last == json['priority'],
        orElse: () => NotificationPriority.normal,
      ),
      fcmSent: json['fcm_sent'] ?? false,
      fcmSentAt: json['fcm_sent_at'] != null ? DateTime.parse(json['fcm_sent_at']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : (json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now()),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : (json['updated_at'] != null ? DateTime.parse(json['updated_at']) : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'body': body,
      'type': type.toString().split('.').last,
      'recipient_id': recipientId.toJson(),
      'sender_id': senderId?.toJson(),
      'related_entity_id': relatedEntityId,
      'related_entity_type': relatedEntityType?.toString().split('.').last,
      'data': data,
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
      'click_action': clickAction,
      'priority': priority.toString().split('.').last,
      'fcm_sent': fcmSent,
      'fcm_sent_at': fcmSentAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class PaginatedNotifications {
  final List<NotificationModel> notifications;
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPrevPage;

  PaginatedNotifications({
    required this.notifications,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory PaginatedNotifications.fromJson(Map<String, dynamic> json) {
    return PaginatedNotifications(
      notifications: (json['notifications'] as List)
          .map((item) => NotificationModel.fromJson(item))
          .toList(),
      total: json['total'],
      page: json['page'],
      limit: json['limit'],
      totalPages: json['totalPages'],
      hasNextPage: json['hasNextPage'],
      hasPrevPage: json['hasPrevPage'],
    );
  }
}

class NotificationStats {
  final int total;
  final int unread;
  final int read;
  final List<NotificationTypeCount> byType;

  NotificationStats({
    required this.total,
    required this.unread,
    required this.read,
    required this.byType,
  });

  factory NotificationStats.fromJson(Map<String, dynamic> json) {
    return NotificationStats(
      total: json['total'],
      unread: json['unread'],
      read: json['read'],
      byType: (json['byType'] as List)
          .map((item) => NotificationTypeCount.fromJson(item))
          .toList(),
    );
  }
}

class NotificationTypeCount {
  final NotificationType type;
  final int count;

  NotificationTypeCount({
    required this.type,
    required this.count,
  });

  factory NotificationTypeCount.fromJson(Map<String, dynamic> json) {
    return NotificationTypeCount(
      type: NotificationType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => NotificationType.announcement,
      ),
      count: json['count'],
    );
  }
}

class UserModel {
  final String id;
  final String name;
  final String? email;

  UserModel({
    required this.id,
    required this.name,
    this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['_id'],
      name: json['name'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
    };
  }
}

enum NotificationType {
  taskAssigned,
  taskUpdated,
  taskDueReminder,
  courseReschedule,
  assignmentGraded,
  classCancelled,
  announcement,
  systemUpdate,
}

enum NotificationPriority {
  low,
  normal,
  high,
  urgent,
}

enum RelatedEntityType {
  task,
  course,
  assignment,
  classTest,
  announcement,
  other,
}