import 'package:flutter/material.dart';
import '../../controllers/chat/chat_controller.dart';
import '../../services/chat/chat_graphql_service.dart';
import '../../config/app_config.dart';
import 'chat_screen_view.dart';

class UserSearchScreen extends StatefulWidget {
  final ChatController chatController;

  const UserSearchScreen({
    Key? key,
    required this.chatController,
  }) : super(key: key);

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final ChatGraphQLService _chatGraphQLService;
  
  List<SearchUser> _searchResults = [];
  List<SearchUser> _recentSearches = [];
  List<SearchUser> _suggestedUsers = [];
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _chatGraphQLService = ChatGraphQLService();
    _loadRecentSearches();
    _loadSuggestedUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    // For now, we'll use empty recent searches
    // In a real app, you'd store and fetch recent searches from local storage
    setState(() {
      _recentSearches = [];
    });
  }

  Future<void> _loadSuggestedUsers() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final users = await _chatGraphQLService.searchUsers('');
      if (users != null && mounted) {
        setState(() {
          _suggestedUsers = users.take(10).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load suggested users';
        });
      }
    }
  }

  Future<void> _searchUsers(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
        _errorMessage = '';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _isSearching = true;
      _errorMessage = '';
    });

    try {
      final users = await _chatGraphQLService.searchUsers(query);
      if (users != null && mounted) {
        setState(() {
          _searchResults = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Search failed. Please try again.';
        });
      }
    }
  }

  Future<void> _saveRecentSearch(String userId) async {
    // For now, we'll skip saving recent searches
    // In a real app, you'd save to local storage
  }

  void _startChat(SearchUser user) async {
    await _saveRecentSearch(user.id);
    
    if (mounted) {
      Navigator.pop(context); // Close search screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreenView(
            withUserId: user.id,
            withUserName: user.name,
            withUserProfilePicture: user.profilePicture,
            chatController: widget.chatController,
            currentUserProfilePicture: widget.chatController.currentUserProfilePicture,
          ),
        ),
      );
    }
  }

  Widget _buildUserTile(SearchUser user, {bool showOnlineStatus = false}) {
    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: user.profilePicture != null
                ? NetworkImage('${AppConfig.imageServer}${user.profilePicture}')
                : null,
            child: user.profilePicture == null
                ? Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          // Online status indicator removed as SearchUser doesn't have isOnline field
        ],
      ),
      title: Text(
        user.name,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () => _startChat(user),
    );
  }

  Widget _buildRecentSearchesGrid() {
    if (_recentSearches.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent searches',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Clear recent searches
                  setState(() {
                    _recentSearches.clear();
                  });
                  // In a real app, you'd clear from local storage here
                },
                child: const Text(
                  'EDIT',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 120,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            scrollDirection: Axis.horizontal,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _recentSearches.length,
            itemBuilder: (context, index) {
              final user = _recentSearches[index];
              return GestureDetector(
                onTap: () => _startChat(user),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: user.profilePicture != null
                          ? NetworkImage('${AppConfig.imageServer}${user.profilePicture}')
                          : null,
                      child: user.profilePicture == null
                          ? Text(
                              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.name.length > 10 ? '${user.name.substring(0, 10)}...' : user.name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Search',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              hintStyle: TextStyle(color: Colors.grey),
            ),
            onChanged: (value) {
              _searchUsers(value);
            },
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: Colors.black),
            onPressed: () {
              // Implement QR code scanner
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_errorMessage.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.red[50],
              child: Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _isSearching
                    ? _buildSearchResults()
                    : _buildDefaultContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No users found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return _buildUserTile(_searchResults[index]);
      },
    );
  }

  Widget _buildDefaultContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRecentSearchesGrid(),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Suggested',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (_suggestedUsers.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No suggested users',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _suggestedUsers.length,
              itemBuilder: (context, index) {
                return _buildUserTile(_suggestedUsers[index]);
              },
            ),
        ],
      ),
    );
  }
}

// SearchUser class is now imported from chat_graphql_service.dart