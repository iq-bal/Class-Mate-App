import 'package:classmate/entity/forum_entity.dart';

class ForumModel {
  final List<ForumPostEntity> posts;
  final int totalCount;
  final int currentPage;
  final bool hasNextPage;

  ForumModel({
    required this.posts,
    required this.totalCount,
    required this.currentPage,
    required this.hasNextPage,
  });

  factory ForumModel.fromJson(Map<String, dynamic> json) {
    return ForumModel(
      posts: json['forumPostsByCourse'] != null
          ? (json['forumPostsByCourse'] as List)
              .map((post) => ForumPostEntity.fromJson(post))
              .toList()
          : [],
      totalCount: json['totalCount'] ?? 0,
      currentPage: json['currentPage'] ?? 1,
      hasNextPage: json['hasNextPage'] ?? false,
    );
  }
}

class CreateForumPostModel {
  final ForumPostEntity post;

  CreateForumPostModel({required this.post});

  factory CreateForumPostModel.fromJson(Map<String, dynamic> json) {
    return CreateForumPostModel(
      post: ForumPostEntity.fromJson(json['createForumPost']),
    );
  }
}

class CreateForumCommentModel {
  final ForumCommentEntity comment;

  CreateForumCommentModel({required this.comment});

  factory CreateForumCommentModel.fromJson(Map<String, dynamic> json) {
    return CreateForumCommentModel(
      comment: ForumCommentEntity.fromJson(json['createForumComment']),
    );
  }
}

class ForumPostDetailModel {
  final ForumPostEntity post;

  ForumPostDetailModel({required this.post});

  factory ForumPostDetailModel.fromJson(Map<String, dynamic> json) {
    return ForumPostDetailModel(
      post: ForumPostEntity.fromJson(json['forumPost']),
    );
  }
}

class ForumSearchModel {
  final List<ForumPostEntity> posts;
  final int totalCount;

  ForumSearchModel({
    required this.posts,
    required this.totalCount,
  });

  factory ForumSearchModel.fromJson(Map<String, dynamic> json) {
    return ForumSearchModel(
      posts: json['searchForumPosts'] != null
          ? (json['searchForumPosts'] as List)
              .map((post) => ForumPostEntity.fromJson(post))
              .toList()
          : [],
      totalCount: json['totalCount'] ?? 0,
    );
  }
}