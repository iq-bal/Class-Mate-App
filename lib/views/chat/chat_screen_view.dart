import 'package:classmate/controllers/chat/socket_controller.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
class ChatScreen extends StatefulWidget {
  final String recipientId; // Pass the recipient ID
  final String token; // Pass the authentication token

  const ChatScreen({super.key, required this.recipientId, required this.token});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final SocketController _socketController = SocketController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Initialize SocketController with the token
    _socketController.initialize(widget.token);

    // Listen for private messages and update the UI
    _socketController.initialize(widget.token);
  }

  @override
  void dispose() {
    _socketController.disconnect(); // Disconnect the socket
    _messageController.dispose();
    super.dispose();
  }

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final SocketController _socketController = SocketController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _socketController.fetchConversation(
      '675936fc1222fe79f3386690', // Replace with the actual user ID
      1, // Page number (start with 1 for initial fetch)
      20, // Number of messages to fetch per page
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      _socketController.sendMessage('675936fc1222fe79f3386690', _messageController.text);
      _messageController.clear();
    }
  }



  void _loadMoreMessages() {
    int nextPage = (_socketController.messagesNotifier.value.length ~/ 20) + 1;
    _socketController.fetchConversation('6761b460591d0a5c3dbaafbc', nextPage, 20);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light background
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Chat Messages Section
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _socketController.messages.length,
              itemBuilder: (context, index) {
                final message = _socketController.messages[index];
                return ChatBubble(
                  isSentByMe: message['isSentByMe'],
                  message: message['message'],
                  time: message['time'],
                );
              },
            ),
          ),
          // Input Section
          _buildInputSection(),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.blue[900],
      title: const Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage('assets/images/avatar.png'),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Niloy Das',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'Online',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      body: Column(
        children: [
          // Chat Messages Section
          Expanded(
            child: ValueListenableBuilder<List<Map<String, dynamic>>>(
              valueListenable: _socketController.messagesNotifier,
              builder: (context, messages, child) {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return ChatBubble(
                      isSentByMe: message.containsKey('to'),
                      message: message['message'],
                      time: message['timestamp'] ?? 'Now',
                    );
                  },
                );
              },
            ),
          ),
          // Input Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.black54),
                  onPressed: () {
                    // Handle attachment
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type Message',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.emoji_emotions_outlined,
                      color: Colors.black54),
                  onPressed: () {
                    // Handle emojis
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.mic, color: Color(0xFF346666)),
                  onPressed: () {
                    // Handle voice input
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
              ],
            ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blue),
            onPressed: () {
              final message = _messageController.text.trim();
              if (message.isNotEmpty) {
                // Send the message through the SocketController
                _socketController.sendMessage(widget.recipientId, message);

                // Add the message to the local list and clear the input
                setState(() {
                  _socketController.messages.add({
                    'isSentByMe': true,
                    'message': message,
                    'time': DateTime.now().toIso8601String(),
                  });
                });
                _messageController.clear();
              }
            },
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final bool isSentByMe;
  final String message;
  final String time;

  const ChatBubble({
    super.key,
    required this.isSentByMe,
    required this.message,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
        isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(12),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            decoration: BoxDecoration(
              color: isSentByMe ? Colors.blue[100] : const Color(0xFFEDEDED),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: isSentByMe
                    ? const Radius.circular(16)
                    : const Radius.circular(0),
                bottomRight: isSentByMe
                    ? const Radius.circular(0)
                    : const Radius.circular(16),
              ),
            ),
            child: Text(
              message,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              time,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ),
        ],
      ),
    );
  }
}
