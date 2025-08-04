import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:classmate/controllers/forum/forum_controller.dart';
import 'package:classmate/entity/forum_entity.dart';
import 'package:classmate/views/forum/widgets/forum_post_card.dart';
import 'package:classmate/views/forum/widgets/create_post_dialog.dart';
import 'package:classmate/views/forum/widgets/forum_post_detail_view.dart';

class ForumView extends StatefulWidget {
  final String courseId;

  const ForumView({super.key, required this.courseId});

  @override
  State<ForumView> createState() => _ForumViewState();
}

class _ForumViewState extends State<ForumView> {
  final ForumController _forumController = ForumController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _forumController.fetchForumPosts(widget.courseId, refresh: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _forumController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _forumController.loadMorePosts(widget.courseId);
    }
  }

  void _showCreatePostDialog() {
    showDialog(
      context: context,
      builder: (context) => CreatePostDialog(
        onCreatePost: (title, content, tags) async {
          final success = await _forumController.createForumPost(
            courseId: widget.courseId,
            title: title,
            content: content,
            tags: tags,
          );
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(success ? 'Post created successfully!' : 'Failed to create post'),
                backgroundColor: success ? Colors.green : Colors.red,
              ),
            );
          }
        },
      ),
    );
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
      });
      _forumController.clearSearchResults();
    } else {
      setState(() {
        _isSearching = true;
      });
      _forumController.searchForumPosts(widget.courseId, query);
    }
  }

  void _navigateToPostDetail(ForumPostEntity post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ForumPostDetailView(
          postId: post.id!,
          forumController: _forumController,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Forum',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              IconButton(
                onPressed: _showCreatePostDialog,
                icon: const Icon(Icons.add_circle, color: Color(0xFF6366F1)),
                tooltip: 'Create Post',
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Search Bar
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search forum posts...',
              hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                      icon: const Icon(Icons.clear, color: Colors.grey),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF6366F1)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),
          
          // Forum Posts List
          Expanded(
            child: ValueListenableBuilder<ForumState>(
              valueListenable: _forumController.stateNotifier,
              builder: (context, state, child) {
                if (state == ForumState.loading && _forumController.postsNotifier.value.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state == ForumState.error) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          _forumController.errorNotifier.value ?? 'Error loading forum posts',
                          style: GoogleFonts.poppins(color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _forumController.fetchForumPosts(widget.courseId, refresh: true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                } else {
                  return _isSearching
                      ? _buildSearchResults()
                      : _buildForumPosts();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return ValueListenableBuilder<List<ForumPostEntity>>(
      valueListenable: _forumController.searchResultsNotifier,
      builder: (context, searchResults, child) {
        if (searchResults.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No posts found for "${_searchController.text}"',
                  style: GoogleFonts.poppins(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          itemCount: searchResults.length,
          itemBuilder: (context, index) {
            final post = searchResults[index];
            return ForumPostCard(
              post: post,
              onTap: () => _navigateToPostDetail(post),
              onUpvote: () => _forumController.upvotePost(post.id!),
              onDownvote: () => _forumController.downvotePost(post.id!),
            );
          },
        );
      },
    );
  }

  Widget _buildForumPosts() {
    return ValueListenableBuilder<List<ForumPostEntity>>(
      valueListenable: _forumController.postsNotifier,
      builder: (context, posts, child) {
        if (posts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.forum_outlined, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No forum posts yet',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Be the first to start a discussion!',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _showCreatePostDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Create First Post'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => _forumController.fetchForumPosts(widget.courseId, refresh: true),
          child: ListView.builder(
            controller: _scrollController,
            itemCount: posts.length + 1,
            itemBuilder: (context, index) {
              if (index == posts.length) {
                return ValueListenableBuilder<bool>(
                  valueListenable: _forumController.hasNextPageNotifier,
                  builder: (context, hasNextPage, child) {
                    if (hasNextPage) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                );
              }

              final post = posts[index];
              return ForumPostCard(
                post: post,
                onTap: () => _navigateToPostDetail(post),
                onUpvote: () => _forumController.upvotePost(post.id!),
                onDownvote: () => _forumController.downvotePost(post.id!),
              );
            },
          ),
        );
      },
    );
  }
}