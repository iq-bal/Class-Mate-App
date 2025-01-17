import 'package:flutter/material.dart';
import 'package:classmate/services/chat/socket_services.dart';
import 'package:socket_io_client/src/socket.dart';

enum SocketState { idle, connecting, connected, error, disconnected }

class SocketController {
  final SocketService _socketService = SocketService();
  final ValueNotifier<SocketState> stateNotifier = ValueNotifier<SocketState>(SocketState.idle);
  final ValueNotifier<List<Map<String, dynamic>>> messagesNotifier = ValueNotifier([]); // List of messages
  String? errorMessage;

  Future<void> initializeSocket() async {
    stateNotifier.value = SocketState.connecting;
    try {
      await _socketService.initializeSocketConnection();
      stateNotifier.value = SocketState.connected;
      _listenToIncomingMessages();
    } catch (e) {
      errorMessage = e.toString();
      stateNotifier.value = SocketState.error;
    }
  }

  void disconnectSocket() {
    try {
      _socketService.disconnectSocket();
      stateNotifier.value = SocketState.disconnected;
    } catch (e) {
      errorMessage = e.toString();
      stateNotifier.value = SocketState.error;
    }
  }

  void sendMessage(String recipientId, String message) {
    try {
      _socketService.sendMessage(recipientId, message);
      // Add the sent message to the local list
      messagesNotifier.value = [
        ...messagesNotifier.value,
        {'to': recipientId, 'message': message, 'isSent': true, 'timestamp': DateTime.now().toString()}
      ];
    } catch (e) {
      errorMessage = e.toString();
    }
  }


  void fetchConversation(String withUserId, int page, int limit) {
    try {

      print('Emitting getConversation event with: $withUserId, page: $page, limit: $limit');


      _socketService.getConversation(
        withUserId,
        page,
        limit,
            (conversationData) {
              print('Conversation data received: $conversationData');
          // Update the messagesNotifier with the fetched messages
          // List<Map<String, dynamic>> fetchedMessages =
          // List<Map<String, dynamic>>.from(conversationData['messages']);
          // Merge fetched messages with the existing list
          // messagesNotifier.value = [...messagesNotifier.value, ...fetchedMessages];
        },
      );
    } catch (e) {
      print('Error in fetchConversation: $errorMessage');
      errorMessage = e.toString();
    }
  }

  void _listenToIncomingMessages() {
    _socketService.listenForIncomingMessages((data) {
      // Add the received message to the local list
      messagesNotifier.value = [
        ...messagesNotifier.value,
        {'from': data['from'], 'message': data['content'], 'timestamp': data['timestamp']}
      ];
    });
  }
}
