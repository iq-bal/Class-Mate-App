import 'package:flutter/foundation.dart';
import 'package:classmate/services/forum/forum_services.dart';
import 'package:classmate/entity/forum_entity.dart';

enum ForumState {
  initial,
  loading,
  loaded,
  error,
  creating,
  created,
}

class ForumController {
  final ForumServices _forumServices = ForumServices();

  // State management
  final ValueNotifier<ForumState> _stateNotifier = ValueNotifier(ForumState.initial);
  final ValueNotifier<String?> _errorNotifier = ValueNotifier(null);
  final ValueNotifier<List<ForumPostEntity>> _postsNotifier = ValueNotifier([]);
  final ValueNotifier<ForumPostEntity?> _selectedPostNotifier = ValueNotifier(null);
  final ValueNotifier<bool> _hasNextPageNotifier = ValueNotifier(false);
  final ValueNotifier<int> _currentPageNotifier = ValueNotifier(1);
  final ValueNotifier<List<ForumPostEntity>> _searchResultsNotifier = ValueNotifier([]);

  // Getters
  ValueListenable<ForumState> get stateNotifier => _stateNotifier;
  ValueListenable<String?> get errorNotifier => _errorNotifier;
  ValueListenable<List<ForumPostEntity>> get postsNotifier => _postsNotifier;
  ValueListenable<ForumPostEntity?> get selectedPostNotifier => _selectedPostNotifier;
  ValueListenable<bool> get hasNextPageNotifier => _hasNextPageNotifier;
  ValueListenable<int> get currentPageNotifier => _currentPageNotifier;
  ValueListenable<List<ForumPostEntity>> get searchResultsNotifier => _searchResultsNotifier;

  // Fetch forum posts for a course
  Future<void> fetchForumPosts(String courseId, {bool refresh = false}) async {
    try {
      if (refresh) {
        _currentPageNotifier.value = 1;
        _postsNotifier.value = [];
      }

      _stateNotifier.value = ForumState.loading;
      _errorNotifier.value = null;

      final forumModel = await _forumServices.getForumPostsByCourse(
        courseId,
        page: _currentPageNotifier.value,
        limit: 10,
      );

      if (refresh) {
        _postsNotifier.value = forumModel.posts;
      } else {
        _postsNotifier.value = [..._postsNotifier.value, ...forumModel.posts];
      }

      _hasNextPageNotifier.value = forumModel.hasNextPage;
      _stateNotifier.value = ForumState.loaded;
    } catch (e) {
      _errorNotifier.value = e.toString();
      _stateNotifier.value = ForumState.error;

      if (kDebugMode) {
        print('Error fetching forum posts: $e');
      }
    }
  }

  // Load more posts (pagination)
  Future<void> loadMorePosts(String courseId) async {
    if (!_hasNextPageNotifier.value || _stateNotifier.value == ForumState.loading) {
      return;
    }

    _currentPageNotifier.value += 1;
    await fetchForumPosts(courseId);
  }

  // Fetch single forum post with comments
  Future<void> fetchForumPost(String postId) async {
    try {
      _stateNotifier.value = ForumState.loading;
      _errorNotifier.value = null;

      final postDetailModel = await _forumServices.getForumPost(postId);
      _selectedPostNotifier.value = postDetailModel.post;
      _stateNotifier.value = ForumState.loaded;
    } catch (e) {
      _errorNotifier.value = e.toString();
      _stateNotifier.value = ForumState.error;

      if (kDebugMode) {
        print('Error fetching forum post: $e');
      }
    }
  }

  // Create forum post
  Future<bool> createForumPost({
    required String courseId,
    required String title,
    required String content,
    List<String>? tags,
  }) async {
    try {
      _stateNotifier.value = ForumState.creating;
      _errorNotifier.value = null;

      final createPostModel = await _forumServices.createForumPost(
        courseId: courseId,
        title: title,
        content: content,
        tags: tags,
      );

      // Add the new post to the beginning of the list
      final currentPosts = List<ForumPostEntity>.from(_postsNotifier.value);
      currentPosts.insert(0, createPostModel.post);
      _postsNotifier.value = currentPosts;

      _stateNotifier.value = ForumState.created;
      return true;
    } catch (e) {
      _errorNotifier.value = e.toString();
      _stateNotifier.value = ForumState.error;

      if (kDebugMode) {
        print('Error creating forum post: $e');
      }
      return false;
    }
  }

  // Create forum comment
  Future<bool> createForumComment({
    required String postId,
    required String content,
    String? parentCommentId,
  }) async {
    try {
      _errorNotifier.value = null;

      await _forumServices.createForumComment(
        postId: postId,
        content: content,
        parentCommentId: parentCommentId,
      );

      // Refresh the post to get updated comments
      await fetchForumPost(postId);
      return true;
    } catch (e) {
      _errorNotifier.value = e.toString();

      if (kDebugMode) {
        print('Error creating forum comment: $e');
      }
      return false;
    }
  }

  // Upvote forum post
  Future<void> upvotePost(String postId) async {
    try {
      await _forumServices.upvoteForumPost(postId);
      
      // Update the post in the list
      _updatePostInList(postId, (post) {
        return ForumPostEntity(
          id: post.id,
          courseId: post.courseId,
          author: post.author,
          title: post.title,
          content: post.content,
          tags: post.tags,
          isPinned: post.isPinned,
          isResolved: post.isResolved,
          views: post.views,
          upvoteCount: (post.upvoteCount ?? 0) + 1,
          downvoteCount: post.downvoteCount,
          commentCount: post.commentCount,
          createdAt: post.createdAt,
          updatedAt: post.updatedAt,
          comments: post.comments,
        );
      });
    } catch (e) {
      _errorNotifier.value = e.toString();

      if (kDebugMode) {
        print('Error upvoting post: $e');
      }
    }
  }

  // Downvote forum post
  Future<void> downvotePost(String postId) async {
    try {
      await _forumServices.downvoteForumPost(postId);
      
      // Update the post in the list
      _updatePostInList(postId, (post) {
        return ForumPostEntity(
          id: post.id,
          courseId: post.courseId,
          author: post.author,
          title: post.title,
          content: post.content,
          tags: post.tags,
          isPinned: post.isPinned,
          isResolved: post.isResolved,
          views: post.views,
          upvoteCount: post.upvoteCount,
          downvoteCount: (post.downvoteCount ?? 0) + 1,
          commentCount: post.commentCount,
          createdAt: post.createdAt,
          updatedAt: post.updatedAt,
          comments: post.comments,
        );
      });
    } catch (e) {
      _errorNotifier.value = e.toString();

      if (kDebugMode) {
        print('Error downvoting post: $e');
      }
    }
  }

  // Mark comment as answer
  Future<void> markCommentAsAnswer(String commentId) async {
    try {
      await _forumServices.markCommentAsAnswer(commentId);
      
      // Refresh the selected post to get updated comments
      if (_selectedPostNotifier.value?.id != null) {
        await fetchForumPost(_selectedPostNotifier.value!.id!);
      }
    } catch (e) {
      _errorNotifier.value = e.toString();

      if (kDebugMode) {
        print('Error marking comment as answer: $e');
      }
    }
  }

  // Search forum posts
  Future<void> searchForumPosts(String courseId, String query) async {
    try {
      _stateNotifier.value = ForumState.loading;
      _errorNotifier.value = null;

      final searchModel = await _forumServices.searchForumPosts(courseId, query);
      _searchResultsNotifier.value = searchModel.posts;
      _stateNotifier.value = ForumState.loaded;
    } catch (e) {
      _errorNotifier.value = e.toString();
      _stateNotifier.value = ForumState.error;

      if (kDebugMode) {
        print('Error searching forum posts: $e');
      }
    }
  }

  // Clear search results
  void clearSearchResults() {
    _searchResultsNotifier.value = [];
  }

  // Helper method to update a post in the list
  void _updatePostInList(String postId, ForumPostEntity Function(ForumPostEntity) updater) {
    final currentPosts = List<ForumPostEntity>.from(_postsNotifier.value);
    final postIndex = currentPosts.indexWhere((post) => post.id == postId);
    
    if (postIndex != -1) {
      currentPosts[postIndex] = updater(currentPosts[postIndex]);
      _postsNotifier.value = currentPosts;
    }
  }

  // Helper method to format time ago
  String formatTimeAgo(DateTime? dateTime) {
    if (dateTime == null) return 'Unknown';
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  // Helper method to get post status icon
  String getPostStatusIcon(ForumPostEntity post) {
    if (post.isPinned == true) return '📌';
    if (post.isResolved == true) return '✅';
    return '❓';
  }

  // Helper method to get post status color
  String getPostStatusColor(ForumPostEntity post) {
    if (post.isPinned == true) return 'orange';
    if (post.isResolved == true) return 'green';
    return 'blue';
  }

  // Dispose resources
  // Delete forum post
  Future<bool> deleteForumPost(String postId) async {
    try {
      _stateNotifier.value = ForumState.loading;
      
      final success = await _forumServices.deleteForumPost(postId);
      
      if (success) {
        // Remove the post from the list
        final currentPosts = _postsNotifier.value;
        _postsNotifier.value = currentPosts.where((post) => post.id != postId).toList();
        
        // Also remove from search results if present
        final currentSearchResults = _searchResultsNotifier.value;
        _searchResultsNotifier.value = currentSearchResults.where((post) => post.id != postId).toList();
        
        _stateNotifier.value = ForumState.loaded;
        return true;
      } else {
        _errorNotifier.value = 'Unable to delete the post. Please try again.';
        _stateNotifier.value = ForumState.error;
        return false;
      }
    } catch (e) {
      // Parse error codes and provide user-friendly messages
      final errorString = e.toString();
      String userFriendlyMessage;
      
      if (errorString.contains('AUTHORIZATION_ERROR:')) {
        userFriendlyMessage = errorString.split('AUTHORIZATION_ERROR: ')[1];
      } else if (errorString.contains('POST_NOT_FOUND:')) {
        userFriendlyMessage = errorString.split('POST_NOT_FOUND: ')[1];
      } else if (errorString.contains('ALREADY_DELETED:')) {
        userFriendlyMessage = errorString.split('ALREADY_DELETED: ')[1];
      } else if (errorString.contains('NETWORK_ERROR:')) {
        userFriendlyMessage = errorString.split('NETWORK_ERROR: ')[1];
      } else if (errorString.contains('UNKNOWN_ERROR:')) {
        userFriendlyMessage = errorString.split('UNKNOWN_ERROR: ')[1];
      } else {
        userFriendlyMessage = 'Something went wrong. Please try again later.';
      }
      
      _errorNotifier.value = userFriendlyMessage;
      _stateNotifier.value = ForumState.error;
      
      if (kDebugMode) {
        print('Error deleting post: $e');
      }
      return false;
    }
  }

  void dispose() {
    _stateNotifier.dispose();
    _errorNotifier.dispose();
    _postsNotifier.dispose();
    _selectedPostNotifier.dispose();
    _hasNextPageNotifier.dispose();
    _currentPageNotifier.dispose();
    _searchResultsNotifier.dispose();
  }
}