import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:classmate/controllers/chat/chat_controller.dart';
import 'package:classmate/controllers/authentication/auth_controller.dart';
import 'package:classmate/core/token_storage.dart';
import 'package:classmate/config/app_config.dart';
import 'package:classmate/views/chat/widgets/conversation_tile.dart';
import 'package:classmate/views/chat/widgets/user_search_dialog.dart';
import 'package:classmate/views/chat/user_search_screen.dart';
import 'package:classmate/views/chat/chat_screen_view.dart';
import 'package:classmate/views/chat/call_screen.dart';
import 'package:classmate/views/chat/ai_chat_view.dart';
import 'package:classmate/views/authentication/landing.dart';
import 'package:classmate/services/profile_student/profile_student_service.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  ChatController? _chatController;
  final TokenStorage _tokenStorage = TokenStorage();
  bool _isLoading = true;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      final token = await _tokenStorage.retrieveAccessToken();
      if (token != null) {
        // Extract user ID from token storage
        final userId = await _tokenStorage.retrieveUserId();
        if (userId != null) {
          _currentUserId = userId;
          
          // Fetch current user's profile to get MongoDB ObjectId and profile picture
          String? currentUserProfilePicture;
          String? mongoUserId;
          try {
            final profileService = ProfileStudentService();
            final profile = await profileService.fetchStudentProfile();
            currentUserProfilePicture = profile.profilePicture;
            mongoUserId = profile.id; // This is the MongoDB ObjectId used in chat
          } catch (e) {
            // Continue without profile picture and use UUID as fallback
          }
          
          _chatController = ChatController(
            userId: mongoUserId ?? _currentUserId!, // Use MongoDB ObjectId if available
            baseUrl: AppConfig.socketBaseUrl,
            token: token,
            currentUserProfilePicture: currentUserProfilePicture,
          );
          
          // Set up incoming call handler
          _chatController!.onIncomingCall = _handleIncomingCall;
          
          await _chatController!.loadConversations();
          await _chatController!.loadUnreadMessages();
          
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        } else {
          throw Exception('Please log out and log back in to use chat features');
        }
      } else {
        throw Exception('Access token not found');
      }
    } catch (e) {
      print('Error initializing chat: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _chatController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_chatController == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Failed to initialize chat',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please log out and log back in to use chat features',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _initializeChat,
                    child: const Text('Retry'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () async {
                      final authController = Provider.of<AuthController>(context, listen: false);
                      await authController.logout(context);
                      if (authController.stateNotifier.value == AuthState.success) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LandingPage()),
                          (route) => false,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: const Text('Log Out'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Messages',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserSearchScreen(
                    chatController: _chatController!,
                  ),
                ),
              );
            },
          ),

        ],
      ),
      body: Column(
        children: [
          // AI Chat Section
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[800]!, Colors.blue[600]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.smart_toy,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AI Assistant',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Get instant help with your studies',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AIChatView(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.blue[800],
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Conversations List
          Expanded(
            child: ValueListenableBuilder<List<Conversation>>(
              valueListenable: _chatController!.conversationsNotifier,
              builder: (context, conversations, _) {
                if (conversations.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No conversations yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Start a conversation to see it here',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: conversations.length,
                  itemBuilder: (context, index) {
                    final conversation = conversations[index];
                    return ConversationTile(
                      conversation: conversation,
                      chatController: _chatController!,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

    );
  }

  void _showNewChatDialog() {
    showDialog(
      context: context,
      builder: (context) => UserSearchDialog(
        chatController: _chatController!,
      ),
    );
  }

  void _handleIncomingCall(Map<String, dynamic> callData) {
     Navigator.push(
       context,
       MaterialPageRoute(
         builder: (context) => CallScreen(
           chatController: _chatController!,
           participantId: callData['callerId'] ?? '',
           participantName: callData['callerName'] ?? 'Unknown',
           participantProfilePicture: callData['callerProfilePicture'],
           callType: callData['callType'] ?? 'voice',
           isIncoming: true,
           incomingCallData: callData['callData'],
         ),
       ),
     );
   }
}
