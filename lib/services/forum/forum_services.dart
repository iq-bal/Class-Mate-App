import 'package:dio/dio.dart';
import 'package:classmate/config/app_config.dart';
import 'package:classmate/core/dio_client.dart';
import 'package:classmate/models/forum/forum_model.dart';
import 'package:classmate/entity/forum_entity.dart';

class ForumServices {
  final DioClient dioClient = DioClient();

  // Get forum posts for a course
  Future<ForumModel> getForumPostsByCourse(String courseId, {int page = 1, int limit = 10}) async {
    const String query = '''
    query GetForumPostsByCourse(\$courseId: ID!, \$page: Int, \$limit: Int) {
      forumPostsByCourse(course_id: \$courseId, page: \$page, limit: \$limit) {
        id
        title
        content
        tags
        is_pinned
        is_resolved
        views
        upvote_count
        downvote_count
        comment_count
        author_id {
          id
          name
          profile_picture
        }
        createdAt
        updatedAt
      }
    }
    ''';

    try {
      final variables = {
        'courseId': courseId,
        'page': page,
        'limit': limit,
      };

      final response = await dioClient
          .getDio(AppConfig.graphqlServer)
          .post(
        '/',
        data: {'query': query, 'variables': variables},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['errors'] != null) {
          throw Exception('GraphQL returned errors: ${data['errors']}');
        }
        if (data['data'] != null) {
          return ForumModel.fromJson(data['data']);
        } else {
          throw Exception('Response data is null');
        }
      } else {
        throw Exception('Failed to fetch forum posts. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }

  // Get single forum post with comments
  Future<ForumPostDetailModel> getForumPost(String postId) async {
    const String query = '''
    query GetForumPost(\$id: ID!) {
      forumPost(id: \$id) {
        id
        title
        content
        tags
        is_pinned
        is_resolved
        views
        upvote_count
        downvote_count
        author_id {
          id
          name
          profile_picture
        }
        comments {
          id
          content
          is_answer
          upvote_count
          downvote_count
          reply_count
          author_id {
            id
            name
            profile_picture
          }
          replies {
            id
            content
            upvote_count
            downvote_count
            author_id {
              id
              name
              profile_picture
            }
            createdAt
          }
          createdAt
        }
        createdAt
        updatedAt
      }
    }
    ''';

    try {
      final variables = {'id': postId};

      final response = await dioClient
          .getDio(AppConfig.graphqlServer)
          .post(
        '/',
        data: {'query': query, 'variables': variables},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['errors'] != null) {
          throw Exception('GraphQL returned errors: ${data['errors']}');
        }
        if (data['data'] != null) {
          return ForumPostDetailModel.fromJson(data['data']);
        } else {
          throw Exception('Response data is null');
        }
      } else {
        throw Exception('Failed to fetch forum post. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }

  // Create forum post
  Future<CreateForumPostModel> createForumPost({
    required String courseId,
    required String title,
    required String content,
    List<String>? tags,
  }) async {
    const String mutation = '''
    mutation CreateForumPost(\$input: CreateForumPostInput!) {
      createForumPost(input: \$input) {
        id
        title
        content
        tags
        author_id {
          id
          name
        }
        createdAt
      }
    }
    ''';

    try {
      final variables = {
        'input': {
          'course_id': courseId,
          'title': title,
          'content': content,
          'tags': tags ?? [],
        },
      };

      final response = await dioClient
          .getDio(AppConfig.graphqlServer)
          .post(
        '/',
        data: {'query': mutation, 'variables': variables},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['errors'] != null) {
          throw Exception('GraphQL returned errors: ${data['errors']}');
        }
        if (data['data'] != null) {
          return CreateForumPostModel.fromJson(data['data']);
        } else {
          throw Exception('Response data is null');
        }
      } else {
        throw Exception('Failed to create forum post. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }

  // Create forum comment
  Future<CreateForumCommentModel> createForumComment({
    required String postId,
    required String content,
    String? parentCommentId,
  }) async {
    const String mutation = '''
    mutation CreateForumComment(\$input: CreateForumCommentInput!) {
      createForumComment(input: \$input) {
        id
        content
        author_id {
          id
          name
        }
        createdAt
      }
    }
    ''';

    try {
      final variables = {
        'input': {
          'post_id': postId,
          'content': content,
          if (parentCommentId != null) 'parent_comment_id': parentCommentId,
        },
      };

      final response = await dioClient
          .getDio(AppConfig.graphqlServer)
          .post(
        '/',
        data: {'query': mutation, 'variables': variables},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['errors'] != null) {
          throw Exception('GraphQL returned errors: ${data['errors']}');
        }
        if (data['data'] != null) {
          return CreateForumCommentModel.fromJson(data['data']);
        } else {
          throw Exception('Response data is null');
        }
      } else {
        throw Exception('Failed to create comment. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }

  // Upvote forum post
  Future<ForumPostEntity> upvoteForumPost(String postId) async {
    const String mutation = '''
    mutation UpvoteForumPost(\$id: ID!) {
      upvoteForumPost(id: \$id) {
        id
        upvote_count
        downvote_count
      }
    }
    ''';

    try {
      final variables = {'id': postId};

      final response = await dioClient
          .getDio(AppConfig.graphqlServer)
          .post(
        '/',
        data: {'query': mutation, 'variables': variables},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['errors'] != null) {
          throw Exception('GraphQL returned errors: ${data['errors']}');
        }
        if (data['data'] != null && data['data']['upvoteForumPost'] != null) {
          return ForumPostEntity.fromJson(data['data']['upvoteForumPost']);
        } else {
          throw Exception('Response data is null');
        }
      } else {
        throw Exception('Failed to upvote post. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }

  // Downvote forum post
  Future<ForumPostEntity> downvoteForumPost(String postId) async {
    const String mutation = '''
    mutation DownvoteForumPost(\$id: ID!) {
      downvoteForumPost(id: \$id) {
        id
        upvote_count
        downvote_count
      }
    }
    ''';

    try {
      final variables = {'id': postId};

      final response = await dioClient
          .getDio(AppConfig.graphqlServer)
          .post(
        '/',
        data: {'query': mutation, 'variables': variables},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['errors'] != null) {
          throw Exception('GraphQL returned errors: ${data['errors']}');
        }
        if (data['data'] != null && data['data']['downvoteForumPost'] != null) {
          return ForumPostEntity.fromJson(data['data']['downvoteForumPost']);
        } else {
          throw Exception('Response data is null');
        }
      } else {
        throw Exception('Failed to downvote post. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }

  // Mark comment as answer
  Future<ForumCommentEntity> markCommentAsAnswer(String commentId) async {
    const String mutation = '''
    mutation MarkCommentAsAnswer(\$id: ID!) {
      markCommentAsAnswer(id: \$id) {
        id
        is_answer
        content
        author_id {
          id
          name
        }
      }
    }
    ''';

    try {
      final variables = {'id': commentId};

      final response = await dioClient
          .getDio(AppConfig.graphqlServer)
          .post(
        '/',
        data: {'query': mutation, 'variables': variables},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['errors'] != null) {
          throw Exception('GraphQL returned errors: ${data['errors']}');
        }
        if (data['data'] != null && data['data']['markCommentAsAnswer'] != null) {
          return ForumCommentEntity.fromJson(data['data']['markCommentAsAnswer']);
        } else {
          throw Exception('Response data is null');
        }
      } else {
        throw Exception('Failed to mark comment as answer. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }

  // Search forum posts
  Future<ForumSearchModel> searchForumPosts(String courseId, String query, {int page = 1, int limit = 10}) async {
    const String searchQuery = '''
    query SearchForumPosts(\$courseId: ID!, \$query: String!, \$page: Int, \$limit: Int) {
      searchForumPosts(course_id: \$courseId, query: \$query, page: \$page, limit: \$limit) {
        id
        title
        content
        tags
        is_resolved
        upvote_count
        comment_count
        author_id {
          id
          name
        }
        createdAt
      }
    }
    ''';

    try {
      final variables = {
        'courseId': courseId,
        'query': query,
        'page': page,
        'limit': limit,
      };

      final response = await dioClient
          .getDio(AppConfig.graphqlServer)
          .post(
        '/',
        data: {'query': searchQuery, 'variables': variables},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['errors'] != null) {
          throw Exception('GraphQL returned errors: ${data['errors']}');
        }
        if (data['data'] != null) {
          return ForumSearchModel.fromJson(data['data']);
        } else {
          throw Exception('Response data is null');
        }
      } else {
        throw Exception('Failed to search forum posts. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }
}