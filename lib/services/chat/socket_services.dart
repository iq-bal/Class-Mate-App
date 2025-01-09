import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:classmate/config/app_config.dart';
import 'package:classmate/core/token_storage.dart';
import 'package:dio/dio.dart';

class SocketService {
  late IO.Socket socket;
  final TokenStorage _tokenStorage = TokenStorage();
  bool _isRefreshingToken = false;

  Future<void> initializeSocketConnection() async {
    final token = await _tokenStorage.retrieveAccessToken();
    if (token == null) {
      throw Exception('No access token found');
    }
    _connectSocket(token);
  }

  void _connectSocket(String token) {
    socket = IO.io(
      AppConfig.socketBaseUrl, // Use your WebSocket server base URL
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setAuth({'token': token}) // Pass token for authentication
          .build(),
    );

    // Handle connection success
    socket.onConnect((_) {
      print('Connected to Socket.IO server (Frontend)');
      socket.emit('getUserDetails'); // Optional: Send a test event to ensure connection
    });

    // Handle connection error
    socket.onConnectError((data) {
      print('Connection error (Frontend): $data');
    });

    // Handle disconnect
    socket.onDisconnect((_) {
      print('Disconnected from Socket.IO server (Frontend)');
    });
  }

  void sendMessage(String recipientId, String message) {
    socket.emit('privateMessage', {
      'to': recipientId,
      'message': message,
    });
  }

  void listenForIncomingMessages(Function(Map<String, dynamic>) onMessageReceived) {
    socket.on('privateMessage', (data) {
      print('Received Message: $data');
      onMessageReceived(data); // Notify controller of the new message
    });
  }

  void disconnectSocket() {
    socket.disconnect();
  }
}
