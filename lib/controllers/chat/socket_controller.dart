import 'package:classmate/services/chat/socket_services.dart';

class SocketController {
  final SocketService _socketService = SocketService();

  // Initialize the socket with the token
  void initialize(String token) {
    _socketService.initializeSocketConnection(token);

    // Add additional event listeners if needed
    _socketService.socket.on('userOnline', (data) {
      print('User Online: $data');
      handleUserOnline(data);
    });

    _socketService.socket.on('privateMessage', (data) {
      print('Private Message Received: $data');
      handlePrivateMessage(data);
    });

    _socketService.socket.on('unreadMessages', (data) {
      print('Unread Messages: $data');
      handleUnreadMessages(data);
    });

    _socketService.socket.on('messageError', (data) {
      print('Error: $data');
      handleError(data);
    });
  }

  // Example handler methods
  void handleUserOnline(dynamic data) {
    // Handle the user online event (e.g., update UI or notify)
    print('User is online: ${data['userId']}');
  }

  void handlePrivateMessage(dynamic data) {
    // Handle incoming private messages (e.g., save to local storage or update chat)
    print('Message from ${data['from']}: ${data['content']}');
  }

  void handleUnreadMessages(dynamic data) {
    // Handle unread messages event
    print('Unread Messages: $data');
  }

  void handleError(dynamic data) {
    // Handle errors from the server
    print('Error received: $data');
  }

  // Expose methods for UI interactions
  void sendMessage(String recipientId, String message) {
    _socketService.sendMessage(recipientId, message);
  }

  void markMessageAsRead(String messageId) {
    _socketService.markMessageAsRead(messageId);
  }

  void fetchUnreadMessages() {
    _socketService.fetchUnreadMessages();
  }

  void disconnect() {
    _socketService.disconnectSocket();
  }
}
