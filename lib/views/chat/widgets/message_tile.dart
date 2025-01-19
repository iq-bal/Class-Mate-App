import 'package:classmate/core/token_storage.dart';
import 'package:classmate/views/chat/chat_screen_view.dart';
import 'package:flutter/material.dart';

class MessageTile extends StatelessWidget {
  final String name;
  final String message;
  final String time;
  final bool isPinned;

  const MessageTile({
    super.key,
    required this.name,
    required this.message,
    required this.time,
    this.isPinned = false,
  });


  @override
  Widget build(BuildContext context) {

    final TokenStorage t = TokenStorage();


    return GestureDetector(
      onTap: () {
        // Navigate to your existing ChatScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FutureBuilder<String?>(
              future: t.retrieveAccessToken(), // Fetch the token
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Show loading indicator while waiting for the token
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                  // Handle errors or null token
                  return const Center(child: Text('Failed to retrieve token'));
                } else {
                  // Pass the token to ChatScreen
                  return ChatScreen(
                    recipientId: "aa59d0b7-5ec1-4095-b8d2-3015a75a4c70",
                    token: snapshot.data!,
                  );
                }
              },
            ),
            // builder: (context) => const ChatScreen(recipientId: "675936fc1222fe79f3386690",token: t.retrieveAccessToken(),), // Pass the data
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 28,
              backgroundImage: AssetImage('assets/images/avatar.png'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const Icon(
                  Icons.check_circle,
                  size: 16,
                  color: Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
