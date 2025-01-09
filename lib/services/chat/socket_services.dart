import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;

  void initializeSocketConnection(String token) {
    // Initialize the socket connection
    socket = IO.io(
      'http://localhost:4002',
      IO.OptionBuilder()
          .setTransports(['websocket']) // Use WebSocket transport
          .enableAutoConnect() // Automatically connect
          .setExtraHeaders({'Authorization': 'Bearer $token'}) // Add headers
          .build(),
    );

    // Handle connection success
    socket.onConnect((_) {
      print('Connected to Socket.IO server');
    });

    // Handle connection errors
    socket.onConnectError((data) {
      print('Connection error: $data');
    });

    // Handle disconnect
    socket.onDisconnect((_) {
      print('Disconnected from Socket.IO server');
    });

    // Listen for custom events
    socket.on('userOnline', (data) {
      print('User Online Event: $data');
    });

    socket.on('privateMessage', (data) {
      print('New Private Message: $data');
    });
  }

  void sendMessage(String recipientId, String message) {
    socket.emit('privateMessage', {
      'to': recipientId,
      'message': message,
    });
  }

  void markMessageAsRead(String messageId) {
    socket.emit('markAsRead', {'messageId': messageId});
  }

  void fetchUnreadMessages() {
    socket.emit('getUnreadMessages');
  }

  void disconnectSocket() {
    socket.disconnect();
  }
}
