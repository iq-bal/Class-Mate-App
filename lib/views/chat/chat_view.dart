import 'package:classmate/services/chat/socket_services.dart';
import 'package:classmate/views/chat/ai_chat_view.dart';
import 'package:classmate/views/chat/widgets/message_tile.dart';
import 'package:flutter/material.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final SocketService _socketService = SocketService();

  @override
  void initState() {
    super.initState();
    _initializeSocketConnection();
  }

  @override
  void dispose() {
    _socketService.disconnectSocket(); // Disconnect socket when leaving the page
    super.dispose();
  }

  void _initializeSocketConnection() async {
    try {
      await _socketService.initializeSocketConnection();
      _listenToSocketEvents();
    } catch (e) {
      print('Error initializing socket connection (Frontend): $e');
    }
  }


  void _listenToSocketEvents() {
    // Listen for user online notifications
    _socketService.socket.on('userOnline', (data) {
      print('User Online Event: $data');
      // You can update the UI here with the list of active users
    });

    // Listen for private messages
    _socketService.socket.on('privateMessage', (data) {
      print('New Private Message: $data');
      // Handle new messages here, such as updating the message list
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9), // Light background
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
              decoration: BoxDecoration(
                color: Colors.blue[900],
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    "Hi, Iqbal!",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "You have received",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),
                  const Text(
                    "48 Messages",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Contact List",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 6,
                      itemBuilder: (context, index) => Container(
                        margin: const EdgeInsets.only(right: 12),
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage:
                              const AssetImage('assets/images/avatar.png'),
                              backgroundColor: Colors.grey[300],
                            ),
                            Positioned(
                              bottom: 20,
                              right: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                width: 14,
                                height: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Body Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tabs Section
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.blue[700],
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              "All Messages",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AIChatView()),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.black12),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: Text(
                                "AI Assistant",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Pinned Messages Section
                  const Text(
                    "Pinned Messages (2)",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3A6073),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: List.generate(
                      2,
                          (index) => const MessageTile(
                        name: 'Niloy Das',
                        message: 'Kita khobor, gom achoni ...',
                        time: '10:00 AM',
                        isPinned: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // All Messages Section
                  const Text(
                    "All Messages (8)",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3A6073),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: List.generate(
                      8,
                          (index) => const MessageTile(
                        name: 'Niloy Das',
                        message: 'Kita khobor, gom achoni ...',
                        time: '10:00 AM',
                        isPinned: false,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.blue[700],
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            // Handle new chat
          },
          elevation: 0,
          backgroundColor: Colors.transparent, // Set transparent to show container
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
