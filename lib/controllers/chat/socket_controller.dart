import 'package:classmate/services/chat/socket_services.dart';
import 'package:flutter/material.dart';

enum SocketState { idle, connecting, connected, error, disconnected }

class SocketController {
  final SocketService _socketService = SocketService();
  final ValueNotifier<SocketState> stateNotifier = ValueNotifier<SocketState>(SocketState.idle);
  final List<Map<String, dynamic>> messages = []; // To store messages locally
  String? errorMessage;

  /// Initialize the Socket Connection
  Future<void> initializeSocket() async {
    stateNotifier.value = SocketState.connecting;
    try {
      await _socketService.initializeSocketConnection();
      stateNotifier.value = SocketState.connected;
      _listenToSocketEvents();
    } catch (e) {
      errorMessage = e.toString();
      stateNotifier.value = SocketState.error;
    }
  }

  /// Disconnect the Socket Connection
  void disconnectSocket() {
    try {
      _socketService.disconnectSocket();
      stateNotifier.value = SocketState.disconnected;
    } catch (e) {
      errorMessage = e.toString();
      stateNotifier.value = SocketState.error;
    }
  }

  /// Send a Message
  void sendMessage(String recipientId, String message) {
    try {
      _socketService.sendMessage(recipientId, message);
      messages.add({'to': recipientId, 'message': message, 'isSent': true});
    } catch (e) {
      errorMessage = e.toString();
      messages.add({'to': recipientId, 'message': message, 'isSent': false});
      stateNotifier.value = SocketState.error;
    }
  }

  /// Fetch Unread Messages
  void fetchUnreadMessages() {
    try {
      _socketService.fetchUnreadMessages();
    } catch (e) {
      errorMessage = e.toString();
      stateNotifier.value = SocketState.error;
    }
  }

  /// Mark a Message as Read
  void markMessageAsRead(String messageId) {
    try {
      _socketService.markMessageAsRead(messageId);
    } catch (e) {
      errorMessage = e.toString();
      stateNotifier.value = SocketState.error;
    }
  }

  /// Fetch Message History with a User
  void fetchMessageHistory(String withUserId) {
    try {
      _socketService.fetchMessageHistory(withUserId);
    } catch (e) {
      errorMessage = e.toString();
      stateNotifier.value = SocketState.error;
    }
  }

  /// Listen to Incoming Socket Events
  void _listenToSocketEvents() {
    _socketService.socket.on('privateMessage', (data) {
      print('New Private Message: $data');
      messages.add({'from': data['from'], 'message': data['content'], 'timestamp': data['timestamp']});
      // Notify listeners or update UI
    });

    _socketService.socket.on('userOnline', (data) {
      print('User Online: $data');
      // Handle user online event
    });

    _socketService.socket.on('userOffline', (data) {
      print('User Offline: $data');
      // Handle user offline event
    });

    _socketService.socket.on('unreadMessages', (data) {
      print('Unread Messages: $data');
      // Handle unread messages
    });

    _socketService.socket.on('messageMarkedRead', (data) {
      print('Message Marked as Read: $data');
      // Handle message read confirmation
    });

    _socketService.socket.on('messageHistory', (data) {
      print('Message History: $data');
      // Handle message history data
    });
  }
}
