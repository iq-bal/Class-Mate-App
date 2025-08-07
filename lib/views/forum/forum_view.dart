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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  // Bottom sheet handle
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  // Content
                  Expanded(
                    child: CreatePostDialog(
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
                  ),
                ],
              ),
            );
          },
        );
      },
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
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showCreatePostDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New Post'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search forum posts...',
                hintStyle: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 14),
                prefixIcon: Icon(Icons.search, color: Colors.grey[600], size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                        icon: Icon(Icons.clear, color: Colors.grey[600], size: 18),
                        splashRadius: 20,
                      )
                    : null,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              style: GoogleFonts.poppins(fontSize: 14),
            ),
          ),
          const SizedBox(height: 10),
          
          // Forum Posts List
          Expanded(
            child: ValueListenableBuilder<ForumState>(
              valueListenable: _forumController.stateNotifier,
              builder: (context, state, child) {
                if (state == ForumState.loading && _forumController.postsNotifier.value.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading forum posts...',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (state == ForumState.error) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.error_outline, size: 40, color: Colors.red[400]),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _forumController.errorNotifier.value ?? 'Error loading forum posts',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please try again',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => _forumController.fetchForumPosts(widget.courseId, refresh: true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
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
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.search_off, size: 40, color: Colors.grey[500]),
                ),
                const SizedBox(height: 16),
                Text(
                  'No posts found for "${_searchController.text}"',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Try a different search term',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.zero,
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
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.forum_outlined, size: 40, color: const Color(0xFF6366F1)),
                ),
                const SizedBox(height: 20),
                Text(
                  'No forum posts yet',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Be the first to start a discussion with your classmates!',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _showCreatePostDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Create First Post'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => _forumController.fetchForumPosts(widget.courseId, refresh: true),
          color: const Color(0xFF6366F1),
          child: ListView.builder(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: posts.length + 1,
            itemBuilder: (context, index) {
              if (index == posts.length) {
                return ValueListenableBuilder<bool>(
                  valueListenable: _forumController.hasNextPageNotifier,
                  builder: (context, hasNextPage, child) {
                    if (hasNextPage) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: SizedBox(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                            ),
                          ),
                        ),
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