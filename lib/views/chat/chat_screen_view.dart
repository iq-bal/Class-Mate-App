import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light background
      appBar: AppBar(
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
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              // Handle options
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat Messages Section
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: const [
                ChatBubble(
                  isSentByMe: false,
                  message:
                  'Hello how is it going down there? are you available for work today? '
                      'I have a new idea regarding the project. I want to discuss about it in all possible ways.',
                  time: '10:01 AM',
                ),
                ChatBubble(
                  isSentByMe: true,
                  message:
                  'Hello how is it going down there? are you available for work today? '
                      'I have a new idea regarding the project. I want to discuss about it in all possible ways.',
                  time: '10:01 AM',
                ),
                ChatBubble(
                  isSentByMe: false,
                  message:
                  'Hello how is it going down there? are you available for work today? '
                      'I have a new idea regarding the project. I want to discuss about it in all possible ways.',
                  time: '10:01 AM',
                ),
                ChatBubble(
                  isSentByMe: true,
                  message:
                  'Hello how is it going down there? are you available for work today? '
                      'I have a new idea regarding the project. I want to discuss about it in all possible ways.',
                  time: '10:01 AM',
                ),
              ],
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
              ],
            ),
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
              color: isSentByMe ? Colors.white : const Color(0xFFEDEDED),
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              time,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
