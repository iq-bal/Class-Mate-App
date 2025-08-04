import 'package:classmate/entity/user_entity.dart';

class ForumPostEntity {
  final String? id;
  final String? courseId;
  final UserEntity? author;
  final String? title;
  final String? content;
  final List<String>? tags;
  final bool? isPinned;
  final bool? isResolved;
  final int? views;
  final int? upvoteCount;
  final int? downvoteCount;
  final int? commentCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<ForumCommentEntity>? comments;

  ForumPostEntity({
    this.id,
    this.courseId,
    this.author,
    this.title,
    this.content,
    this.tags,
    this.isPinned,
    this.isResolved,
    this.views,
    this.upvoteCount,
    this.downvoteCount,
    this.commentCount,
    this.createdAt,
    this.updatedAt,
    this.comments,
  });

  // Helper method to parse DateTime from various formats
  static DateTime? _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return null;
    
    try {
      // If it's a string that looks like a Unix timestamp
      if (dateValue is String && RegExp(r'^\d+$').hasMatch(dateValue)) {
        final timestamp = int.parse(dateValue);
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
      // If it's an integer timestamp
      else if (dateValue is int) {
        return DateTime.fromMillisecondsSinceEpoch(dateValue);
      }
      // Otherwise try to parse as ISO date string
      else if (dateValue is String) {
        return DateTime.parse(dateValue);
      }
    } catch (e) {
      // Return null if parsing fails
      return null;
    }
    return null;
  }

  factory ForumPostEntity.fromJson(Map<String, dynamic> json) {
    return ForumPostEntity(
      id: json['id'],
      courseId: json['course_id'],
      author: json['author_id'] != null ? UserEntity.fromJson(json['author_id']) : null,
      title: json['title'],
      content: json['content'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      isPinned: json['is_pinned'],
      isResolved: json['is_resolved'],
      views: json['views'],
      upvoteCount: json['upvote_count'],
      downvoteCount: json['downvote_count'],
      commentCount: json['comment_count'],
      createdAt: json['createdAt'] != null ? _parseDateTime(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? _parseDateTime(json['updatedAt']) : null,
      comments: json['comments'] != null
          ? (json['comments'] as List).map((comment) => ForumCommentEntity.fromJson(comment)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'author_id': author?.toJson(),
      'title': title,
      'content': content,
      'tags': tags,
      'is_pinned': isPinned,
      'is_resolved': isResolved,
      'views': views,
      'upvote_count': upvoteCount,
      'downvote_count': downvoteCount,
      'comment_count': commentCount,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'comments': comments?.map((comment) => comment.toJson()).toList(),
    };
  }
}

class ForumCommentEntity {
  final String? id;
  final String? postId;
  final UserEntity? author;
  final String? content;
  final String? parentCommentId;
  final bool? isAnswer;
  final int? upvoteCount;
  final int? downvoteCount;
  final int? replyCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<ForumCommentEntity>? replies;

  ForumCommentEntity({
    this.id,
    this.postId,
    this.author,
    this.content,
    this.parentCommentId,
    this.isAnswer,
    this.upvoteCount,
    this.downvoteCount,
    this.replyCount,
    this.createdAt,
    this.updatedAt,
    this.replies,
  });

  // Helper method to parse DateTime from various formats
  static DateTime? _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return null;
    
    try {
      // If it's a string that looks like a Unix timestamp
      if (dateValue is String && RegExp(r'^\d+$').hasMatch(dateValue)) {
        final timestamp = int.parse(dateValue);
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
      // If it's an integer timestamp
      else if (dateValue is int) {
        return DateTime.fromMillisecondsSinceEpoch(dateValue);
      }
      // Otherwise try to parse as ISO date string
      else if (dateValue is String) {
        return DateTime.parse(dateValue);
      }
    } catch (e) {
      // Return null if parsing fails
      return null;
    }
    return null;
  }

  factory ForumCommentEntity.fromJson(Map<String, dynamic> json) {
    return ForumCommentEntity(
      id: json['id'],
      postId: json['post_id'],
      author: json['author_id'] != null ? UserEntity.fromJson(json['author_id']) : null,
      content: json['content'],
      parentCommentId: json['parent_comment_id'],
      isAnswer: json['is_answer'],
      upvoteCount: json['upvote_count'],
      downvoteCount: json['downvote_count'],
      replyCount: json['reply_count'],
      createdAt: json['createdAt'] != null ? _parseDateTime(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? _parseDateTime(json['updatedAt']) : null,
      replies: json['replies'] != null
          ? (json['replies'] as List).map((reply) => ForumCommentEntity.fromJson(reply)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'author_id': author?.toJson(),
      'content': content,
      'parent_comment_id': parentCommentId,
      'is_answer': isAnswer,
      'upvote_count': upvoteCount,
      'downvote_count': downvoteCount,
      'reply_count': replyCount,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'replies': replies?.map((reply) => reply.toJson()).toList(),
    };
  }
}