import 'package:classmate/models/chat/message.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path/path.dart' as path;

class ChatService extends ChangeNotifier {
  late IO.Socket socket;
  final String userId;
  final String baseUrl;
  final String token;
  bool isConnected = false;
  final Map<String, bool> typingStatus = {};
  final Map<String, List<Message>> conversations = {};

  ChatService({
    required this.userId,
    required this.baseUrl,
    required this.token,
  }) {
    _initializeSocket();
  }

  void _initializeSocket() {
    socket = IO.io(baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'auth': {'token': token},
      'query': {'userId': userId}
    });

    socket.onConnect((_) {
      isConnected = true;
      print('Connected to chat server');
      notifyListeners();
    });

    socket.onDisconnect((_) {
      isConnected = false;
      print('Disconnected from chat server');
      notifyListeners();
    });

    _setupMessageListeners();
    socket.connect();
  }

  void _setupMessageListeners() {
    // New message received
    socket.on('message', (data) {
      final message = Message.fromJson(data);
      _addMessageToConversation(message);
      notifyListeners();
    });

    // Typing status
    socket.on('typing', (data) {
      typingStatus[data['userId']] = data['isTyping'];
      notifyListeners();
    });

    // Message read status
    socket.on('messageRead', (data) {
      _updateMessageReadStatus(data['messageId'], data['readAt']);
      notifyListeners();
    });

    // Message reactions
    socket.on('messageReaction', (data) {
      _updateMessageReaction(data);
      notifyListeners();
    });

    // Message edited
    socket.on('messageEdited', (data) {
      _updateEditedMessage(data);
      notifyListeners();
    });

    // Message deleted
    socket.on('messageDeleted', (data) {
      _handleDeletedMessage(data);
      notifyListeners();
    });
  }

  void _addMessageToConversation(Message message) {
    final conversationId = message.senderId == userId
        ? message.receiverId
        : message.senderId;

    if (!conversations.containsKey(conversationId)) {
      conversations[conversationId] = [];
    }
    conversations[conversationId]!.add(message);

    // Mark message as delivered if we're the receiver
    if (message.receiverId == userId) {
      _markMessageAsDelivered(message.id);
    }
  }

  void _updateMessageReadStatus(String messageId, DateTime readAt) {
    conversations.forEach((_, messages) {
      final index = messages.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        messages[index] = messages[index].copyWith(
          read: true,
          readAt: readAt,
        );
      }
    });
  }

  void _updateMessageReaction(Map<String, dynamic> data) {
    final String messageId = data['messageId'];
    final String userId = data['userId'];
    final String reaction = data['reaction'];

    conversations.forEach((_, messages) {
      final index = messages.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        final message = messages[index];
        message.reactions.removeWhere((r) => r.userId == userId);
        message.reactions.add(MessageReaction(
          userId: userId,
          reaction: reaction,
          createdAt: DateTime.now(),
        ));
      }
    });
  }

  void _updateEditedMessage(Map<String, dynamic> data) {
    final String messageId = data['messageId'];
    final String newContent = data['content'];

    conversations.forEach((_, messages) {
      final index = messages.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        messages[index] = messages[index].copyWith(
          content: newContent,
          edited: true,
          editedAt: DateTime.now(),
        );
      }
    });
  }

  void _handleDeletedMessage(Map<String, dynamic> data) {
    final String messageId = data['messageId'];
    final bool forEveryone = data['forEveryone'];

    conversations.forEach((_, messages) {
      if (forEveryone) {
        messages.removeWhere((m) => m.id == messageId);
      } else {
        final index = messages.indexWhere((m) => m.id == messageId);
        if (index != -1) {
          messages[index] = messages[index].copyWith(
            deletedFor: [...messages[index].deletedFor, data['userId']],
          );
        }
      }
    });
  }

  void _markMessageAsDelivered(String messageId) {
    socket.emit('messageDelivered', {
      'messageId': messageId,
      'deliveredAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> sendMessage({
    required String receiverId,
    required String content,
    String type = 'text',
    File? file,
    Message? replyTo,
    bool isForwarded = false,
    String? forwardedFrom,
  }) async {
    String? fileUrl;
    String? fileName;
    int? fileSize;
    String? fileType;
    String? thumbnailUrl;
    int? duration;

    // Handle file upload if present
    if (file != null) {
      final uploadResult = await _uploadFile(file, type);
      fileUrl = uploadResult['fileUrl'];
      fileName = path.basename(file.path);
      fileSize = await file.length();
      fileType = uploadResult['fileType'];
      thumbnailUrl = uploadResult['thumbnailUrl'];
      duration = uploadResult['duration'];
    }

    final message = {
      'senderId': userId,
      'receiverId': receiverId,
      'content': content,
      'messageType': type,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'fileSize': fileSize,
      'fileType': fileType,
      'thumbnailUrl': thumbnailUrl,
      'duration': duration,
      'replyTo': replyTo?.id,
      'forwarded': isForwarded,
      'forwardedFrom': forwardedFrom,
    };

    socket.emit('message', message);
  }

  Future<Map<String, dynamic>> _uploadFile(File file, String type) async {
    try {
      final uri = Uri.parse('$baseUrl/upload');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseData);

      if (response.statusCode != 200) {
        throw Exception('Failed to upload file: ${jsonResponse['message']}');
      }

      return jsonResponse;
    } catch (e) {
      print('Error uploading file: $e');
      rethrow;
    }
  }

  void sendTypingStatus(String receiverId, bool isTyping) {
    socket.emit('typing', {
      'receiverId': receiverId,
      'isTyping': isTyping,
    });
  }

  void markMessageAsRead(String messageId) {
    socket.emit('messageRead', {
      'messageId': messageId,
      'readAt': DateTime.now().toIso8601String(),
    });
  }

  void reactToMessage(String messageId, String reaction) {
    socket.emit('messageReaction', {
      'messageId': messageId,
      'reaction': reaction,
    });
  }

  void editMessage(String messageId, String newContent) {
    socket.emit('editMessage', {
      'messageId': messageId,
      'content': newContent,
    });
  }

  void deleteMessage(String messageId, {bool forEveryone = false}) {
    socket.emit('deleteMessage', {
      'messageId': messageId,
      'forEveryone': forEveryone,
    });
  }

  Future<List<Message>> loadMessages(String conversationId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/messages/$conversationId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load messages');
      }

      final List<dynamic> data = json.decode(response.body);
      final messages = data.map((m) => Message.fromJson(m)).toList();

      conversations[conversationId] = messages;
      notifyListeners();

      return messages;
    } catch (e) {
      print('Error loading messages: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getConversations(String receiverId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/conversations'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load conversations');
      }

      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } catch (e) {
      print('Error loading conversations: $e');
      rethrow;
    }
  }

  void dispose() {
    socket.disconnect();
    socket.dispose();
    super.dispose();
  }

  void sendTypingIndicator(String receiverId) {}

  void sendStopTypingIndicator(String receiverId) {}
}