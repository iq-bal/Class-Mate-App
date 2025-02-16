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
    return Message(
      id: json['_id'],
      senderId: json['sender_id']['_id'],
      receiverId: json['receiver_id']['_id'],
      content: json['content'],
      messageType: json['message_type'],
      fileUrl: json['file_url'],
      fileName: json['file_name'],
      fileSize: json['file_size'],
      fileType: json['file_type'],
      duration: json['duration'],
      thumbnailUrl: json['thumbnail_url'],
      reactions: (json['reactions'] as List?)
          ?.map((r) => MessageReaction.fromJson(r))
          .toList() ?? [],
      replyTo: json['reply_to']?['_id'],
      forwarded: json['forwarded'] ?? false,
      forwardedFrom: json['forwarded_from']?['_id'],
      read: json['read'] ?? false,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      delivered: json['delivered'] ?? false,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'])
          : null,
      edited: json['edited'] ?? false,
      editedAt: json['edited_at'] != null
          ? DateTime.parse(json['edited_at'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
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
    return MessageReaction(
      userId: json['user_id'],
      reaction: json['reaction'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}