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


  void _listenToServerEvents() {
    // Listen for user online notifications
    socket.on('userOnline', (data) {
      print('User Online Event: $data');
    });

    // Listen for private messages
    socket.on('privateMessage', (data) {
      print('New Private Message: $data');
    });

    // Listen for unread messages
    socket.on('unreadMessages', (data) {
      print('Unread Messages: $data');
    });

    // Listen for message read confirmation
    socket.on('messageMarkedRead', (data) {
      print('Message marked as read: $data');
    });

    // Listen for message history
    socket.on('messageHistory', (data) {
      print('Message History: $data');
    });

    // Listen for user offline notifications
    socket.on('userOffline', (data) {
      print('User Offline Event: $data');
    });
  }

  Future<void> _handleTokenRefresh() async {
    if (_isRefreshingToken) return; // Prevent multiple token refresh attempts
    _isRefreshingToken = true;

    try {
      final isTokenRefreshed = await _refreshToken();
      if (isTokenRefreshed) {
        final newToken = await _tokenStorage.retrieveAccessToken();
        if (newToken != null) {
          // Reconnect the socket with the new token
          socket.disconnect();
          _connectSocket(newToken);
        }
      } else {
        print('Token refresh failed');
        socket.disconnect(); // Disconnect the socket if refresh fails
      }
    } catch (e) {
      print('Error during token refresh: $e');
      socket.disconnect();
    } finally {
      _isRefreshingToken = false;
    }
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _tokenStorage.retrieveRefreshToken();
      if (refreshToken == null) return false;

      final dio = Dio(BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: AppConfig.timeoutDuration),
        receiveTimeout: const Duration(seconds: AppConfig.timeoutDuration),
      ));

      final response = await dio.post(
        '/token',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['accessToken'];
        await _tokenStorage.storeToken(newAccessToken, refreshToken);
        return true;
      }
    } catch (e) {
      print('Error during token refresh: $e');
    }
    return false;
  }

  void sendMessage(String recipientId, String message) {
    socket.emit('privateMessage', {
      'to': recipientId,
      'message': message,
    });
  }

  void fetchUnreadMessages() {
    socket.emit('getUnreadMessages');
  }

  void markMessageAsRead(String messageId) {
    socket.emit('markAsRead', {'messageId': messageId});
  }

  void fetchMessageHistory(String withUserId) {
    socket.emit('getMessageHistory', {'withUserId': withUserId});
  }

  void disconnectSocket() {
    socket.disconnect();
  }
}
