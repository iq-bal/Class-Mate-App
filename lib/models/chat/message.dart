class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final String messageType;
  final String? fileUrl;
  final String? fileName;
  final int? fileSize;
  final String? fileType;
  final int? duration;
  final String? thumbnailUrl;
  final List<MessageReaction> reactions;
  final String? replyTo;
  final Message? replyToMessage;
  final bool forwarded;
  final String? forwardedFrom;
  final bool read;
  final DateTime? readAt;
  final bool delivered;
  final DateTime? deliveredAt;
  final bool edited;
  final DateTime? editedAt;
  final DateTime createdAt;
  final List<String> deletedFor;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.messageType,
    this.fileUrl,
    this.fileName,
    this.fileSize,
    this.fileType,
    this.duration,
    this.thumbnailUrl,
    required this.reactions,
    this.replyTo,
    this.replyToMessage,
    required this.forwarded,
    this.forwardedFrom,
    required this.read,
    this.readAt,
    required this.delivered,
    this.deliveredAt,
    required this.edited,
    this.editedAt,
    required this.createdAt,
    this.deletedFor = const [],
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    String senderId = '';
    String receiverId = '';
    
    // Handle different sender_id structures (string from socket, object from GraphQL)
    if (json['sender_id'] is String) {
      senderId = json['sender_id'];
    } else if (json['sender_id'] is Map) {
      senderId = json['sender_id']?['_id'] ?? json['sender_id']?['id'] ?? '';
    }
    
    // Handle different receiver_id structures (string from socket, object from GraphQL)
    if (json['receiver_id'] is String) {
      receiverId = json['receiver_id'];
    } else if (json['receiver_id'] is Map) {
      receiverId = json['receiver_id']?['_id'] ?? json['receiver_id']?['id'] ?? '';
    }
    
    return Message(
      id: json['_id'] ?? json['id'] ?? '',
      senderId: senderId,
      receiverId: receiverId,
      content: json['content'] ?? '',
      messageType: json['message_type'] ?? 'text',
      fileUrl: json['file_url'],
      fileName: json['file_name'],
      fileSize: json['file_size'],
      fileType: json['file_type'],
      duration: json['duration'],
      thumbnailUrl: json['thumbnail_url'],
      reactions: (json['reactions'] as List?)
          ?.map((r) => MessageReaction.fromJson(r))
          .toList() ?? [],
      replyTo: json['reply_to'] is String 
          ? json['reply_to'] 
          : json['reply_to']?['_id'] ?? json['reply_to']?['id'],
      replyToMessage: json['reply_to'] is Map<String, dynamic>
          ? Message.fromJson(json['reply_to'])
          : null,
      forwarded: json['forwarded'] ?? false,
      forwardedFrom: json['forwarded_from']?['_id'] ?? json['forwarded_from']?['id'],
      read: json['read'] ?? false,
      readAt: json['read_at'] != null && json['read_at'] is String 
          ? DateTime.parse(json['read_at']) 
          : null,
      delivered: json['delivered'] ?? false,
      deliveredAt: json['delivered_at'] != null && json['delivered_at'] is String
          ? DateTime.parse(json['delivered_at'])
          : null,
      edited: json['edited'] ?? false,
      editedAt: json['edited_at'] != null && json['edited_at'] is String
          ? DateTime.parse(json['edited_at'])
          : null,
      createdAt: json['createdAt'] != null && json['createdAt'] is String
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      deletedFor: (json['deleted_for'] as List?)
          ?.map((d) => d['user_id'] as String)
          .toList() ?? [],
    );
  }

  Message copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? content,
    String? messageType,
    String? fileUrl,
    String? fileName,
    int? fileSize,
    String? fileType,
    int? duration,
    String? thumbnailUrl,
    List<MessageReaction>? reactions,
    String? replyTo,
    Message? replyToMessage,
    bool? forwarded,
    String? forwardedFrom,
    bool? read,
    DateTime? readAt,
    bool? delivered,
    DateTime? deliveredAt,
    bool? edited,
    DateTime? editedAt,
    DateTime? createdAt,
    List<String>? deletedFor,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      fileType: fileType ?? this.fileType,
      duration: duration ?? this.duration,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      reactions: reactions ?? this.reactions,
      replyTo: replyTo ?? this.replyTo,
      replyToMessage: replyToMessage ?? this.replyToMessage,
      forwarded: forwarded ?? this.forwarded,
      forwardedFrom: forwardedFrom ?? this.forwardedFrom,
      read: read ?? this.read,
      readAt: readAt ?? this.readAt,
      delivered: delivered ?? this.delivered,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      edited: edited ?? this.edited,
      editedAt: editedAt ?? this.editedAt,
      createdAt: createdAt ?? this.createdAt,
      deletedFor: deletedFor ?? this.deletedFor,
    );
  }
}

class MessageReaction {
  final String userId;
  final String reaction;
  final DateTime createdAt;

  MessageReaction({
    required this.userId,
    required this.reaction,
    required this.createdAt,
  });

  factory MessageReaction.fromJson(Map<String, dynamic> json) {
    // Handle different user_id structures (string from socket, object from GraphQL)
    String userId = '';
    if (json['user_id'] is String) {
      userId = json['user_id'];
    } else if (json['user_id'] is Map) {
      userId = json['user_id']?['_id'] ?? json['user_id']?['id'] ?? '';
    }
    
    return MessageReaction(
      userId: userId,
      reaction: json['reaction'] ?? '',
      createdAt: json['created_at'] != null && json['created_at'] is String
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}