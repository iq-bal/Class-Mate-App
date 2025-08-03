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
  
  // Callback for when a message is deleted via Socket.IO
  Function(String messageId, String conversationUserId)? onMessageDeleted;
  
  // Callback for when a message reaction is updated via Socket.IO
  Function(String messageId, String conversationUserId)? onMessageReactionUpdated;
  
  // Callback for when a message is edited via Socket.IO
  Function(String messageId, String conversationUserId)? onMessageEdited;
  
  // Callback for when a message ID is updated from temporary to real
  Function(String oldId, String newId)? onMessageIdUpdated;

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
      
      // Request missed messages when connecting
      socket.emit('getMissedMessages', {'userId': userId});
      
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

    // Missed messages received when coming online
    socket.on('missedMessages', (data) {
      final List<dynamic> messagesData = data['messages'] ?? [];
      for (final messageData in messagesData) {
        final message = Message.fromJson(messageData);
        _addMessageToConversation(message);
      }
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

    // Message reacted (alternative event name)
     socket.on('messageReacted', (data) {
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
    
    final messages = conversations[conversationId]!;
    
    // Check if this is a response to a temporary message we sent
    if (message.senderId == userId) {
      final tempMessageIndex = messages.indexWhere((m) => 
        m.id.startsWith('temp_') && 
        m.content == message.content &&
        m.senderId == message.senderId &&
        m.receiverId == message.receiverId
      );
      
      if (tempMessageIndex != -1) {
         // Update the temporary message with the real server message
         final tempMessage = messages[tempMessageIndex];
         messages[tempMessageIndex] = message.copyWith(
           createdAt: tempMessage.createdAt, // Keep original timestamp for UI consistency
         );
         
         // Notify about the ID change
         onMessageIdUpdated?.call(tempMessage.id, message.id);
         
         return; // Exit early since we updated the existing message
       }
    }
    
    // Check if message already exists to avoid duplicates
    if (!messages.any((m) => m.id == message.id)) {
      messages.add(message);
    }

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
    final String reactionUserId = data['userId'];
    final String reaction = data['reaction'];
    String? affectedConversationUserId;
    bool messageFound = false;
    
    // Search through all conversations to find the message
    conversations.forEach((conversationUserId, messages) {
      final index = messages.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        messageFound = true;
        final message = messages[index];
        
        // Create a new list of reactions by filtering out existing reactions from this user
        final List<MessageReaction> updatedReactions = List<MessageReaction>.from(
          message.reactions.where((r) => r.userId != reactionUserId)
        );
        
        // Add new reaction
        updatedReactions.add(MessageReaction(
          userId: reactionUserId,
          reaction: reaction,
          createdAt: DateTime.now(),
        ));
        
        // Create a new message with updated reactions
        messages[index] = message.copyWith(reactions: updatedReactions);
        
        affectedConversationUserId = conversationUserId;
      }
    });
    
    if (!messageFound) {
      // Try to determine the conversation based on the current user and reaction user
      if (reactionUserId != userId) {
        // Reaction is from another user, so the conversation key would be their ID
        affectedConversationUserId = reactionUserId;
      }
    }
    
    // Notify the chat controller if a reaction was updated and we have a callback
    if (affectedConversationUserId != null && onMessageReactionUpdated != null) {
      onMessageReactionUpdated!(messageId, affectedConversationUserId!);
    }
  }

  void _updateEditedMessage(Map<String, dynamic> data) {
    final String messageId = data['messageId'];
    final String newContent = data['content'];
    String? affectedConversationUserId;

    conversations.forEach((conversationUserId, messages) {
      final index = messages.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        messages[index] = messages[index].copyWith(
          content: newContent,
          edited: true,
          editedAt: DateTime.now(),
        );
        affectedConversationUserId = conversationUserId;
      }
    });
    
    // Notify the chat controller about the edited message
    if (affectedConversationUserId != null && onMessageEdited != null) {
      onMessageEdited!(messageId, affectedConversationUserId!);
    }
  }

  void _handleDeletedMessage(Map<String, dynamic> data) {
    final String messageId = data['messageId'];
    final bool forEveryone = data['forEveryone'];
    String? affectedConversationUserId;

    conversations.forEach((conversationUserId, messages) {
      if (forEveryone) {
        final hadMessage = messages.any((m) => m.id == messageId);
        messages.removeWhere((m) => m.id == messageId);
        if (hadMessage) {
          affectedConversationUserId = conversationUserId;
        }
      } else {
        final index = messages.indexWhere((m) => m.id == messageId);
        if (index != -1) {
          messages[index] = messages[index].copyWith(
            deletedFor: [...messages[index].deletedFor, data['userId']],
          );
          affectedConversationUserId = conversationUserId;
        }
      }
    });
    
    // Notify the chat controller if a message was deleted and we have a callback
    if (affectedConversationUserId != null && onMessageDeleted != null) {
      onMessageDeleted!(messageId, affectedConversationUserId!);
    }
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
    String? replyToId,
    bool forward = false,
    String? forwardFromId,
  }) async {
    String? fileUrl;
    String? fileName;
    int? fileSize;
    String? fileType;
    String? thumbnailUrl;
    int? duration;

    Map<String, dynamic> message = {
      'to': receiverId,
      'content': content,
      'type': type,
      'senderId': userId,
      'receiverId': receiverId,
      'messageType': type,
      'replyTo': replyTo?.id ?? replyToId,
      'forwarded': isForwarded || forward,
      'forwardedFrom': forwardedFrom ?? forwardFromId,
      if (replyToId != null) 'replyTo': replyToId,
      'forward': forward,
      if (forwardFromId != null) 'forwardFrom': forwardFromId,
    };
    
    // Handle file upload if present
    if (file != null) {
      final uploadResult = await _uploadFile(file, type);
      
      message.addAll({
        'file': {
          'buffer': uploadResult['buffer'], // Send ArrayBuffer directly
          'name': uploadResult['name'],
          'size': uploadResult['size'],
          'type': uploadResult['type'],
        }
      });
    }

    socket.emit('message', message);
  }

  Future<Map<String, dynamic>> _uploadFile(File file, String type) async {
    try {
      // Read file as bytes (equivalent to ArrayBuffer in JavaScript)
      final bytes = await file.readAsBytes();
      final fileName = path.basename(file.path);
      final fileSize = bytes.length;
      
      // Determine file type based on extension
      String fileType = 'application/octet-stream'; // default
      final extension = path.extension(fileName).toLowerCase();
      
      switch (extension) {
        case '.jpg':
        case '.jpeg':
          fileType = 'image/jpeg';
          break;
        case '.png':
          fileType = 'image/png';
          break;
        case '.gif':
          fileType = 'image/gif';
          break;
        case '.webp':
          fileType = 'image/webp';
          break;
        case '.mp4':
          fileType = 'video/mp4';
          break;
        case '.webm':
          fileType = 'video/webm';
          break;
        case '.mp3':
          fileType = 'audio/mpeg';
          break;
        case '.wav':
          fileType = 'audio/wav';
          break;
        case '.pdf':
          fileType = 'application/pdf';
          break;
      }
      
      return {
        'buffer': bytes, // Send bytes directly as buffer
        'name': fileName,
        'size': fileSize,
        'type': fileType,
      };
    } catch (e) {
      throw Exception('Failed to prepare file: $e');
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
    final reactionData = {
      'messageId': messageId,
      'reaction': reaction,
    };
    
    print('🎭 SERVICE REACTION DEBUG: Emitting react event for message $messageId with reaction "$reaction"');
    socket.emit('react', reactionData);
    print('🎭 SERVICE REACTION DEBUG: React event emitted successfully');
  }

  void editMessage(String messageId, String newContent) {
    socket.emit('editMessage', {
      'messageId': messageId,
      'content': newContent,
    });
  }

  void deleteMessage(String messageId, {bool forEveryone = true}) {
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

  // Additional methods for ChatController compatibility
  void sendFileMessage({
    required String receiverId,
    required String content,
    required File file,
    String? replyToId,
  }) {
    sendMessage(
      receiverId: receiverId,
      content: content,
      type: _getFileType(file),
      file: file,
      replyTo: replyToId != null ? _findMessageById(replyToId) : null,
    );
  }

  String _getFileType(File file) {
    final extension = path.extension(file.path).toLowerCase();
    if (['.jpg', '.jpeg', '.png', '.gif'].contains(extension)) {
      return 'image';
    } else if (['.mp4', '.mov', '.avi'].contains(extension)) {
      return 'video';
    } else if (['.mp3', '.wav', '.m4a'].contains(extension)) {
      return 'voice';
    }
    return 'file';
  }

  Message? _findMessageById(String messageId) {
    for (final messages in conversations.values) {
      final message = messages.firstWhere(
        (m) => m.id == messageId,
        orElse: () => throw StateError('Message not found'),
      );
      if (message.id == messageId) return message;
    }
    return null;
  }



  void forwardMessage(String messageId, List<String> toUserIds) {
    socket.emit('forwardMessage', {
      'messageId': messageId,
      'toUserIds': toUserIds,
    });
  }

  void getConversation(String withUserId, int page, int limit) {
    socket.emit('getConversation', {
      'with_user_id': withUserId,
      'page': page,
      'limit': limit,
    });
  }

  // Delete entire conversation
  void deleteConversation(String withUserId) {
    socket.emit('deleteConversation', {
      'with_user_id': withUserId,
    });
  }

  void markMessagesAsRead(String withUserId) {
    socket.emit('markMessagesAsRead', {
      'with_user_id': withUserId,
    });
  }

  void startTyping(String toUserId) {
    socket.emit('typing', {
      'to': toUserId,
    });
  }

  void stopTyping(String toUserId) {
    socket.emit('stopTyping', {
      'to': toUserId,
    });
  }

  void initiateCall(String toUserId, String callType, dynamic signalData) {
    socket.emit('callUser', {
      'to': toUserId,
      'signalData': signalData,
      'callType': callType,
    });
  }

  void answerCall(String toUserId, dynamic signalData) {
    socket.emit('answerCall', {
      'to': toUserId,
      'signalData': signalData,
    });
  }

  void rejectCall(String toUserId) {
    socket.emit('rejectCall', {
      'to': toUserId,
    });
  }

  void endCall(String toUserId) {
    socket.emit('endCall', {
      'to': toUserId,
    });
  }

  void disconnect() {
    socket.disconnect();
  }

  void sendTypingIndicator(String receiverId) {
    startTyping(receiverId);
  }

  void sendStopTypingIndicator(String receiverId) {
    stopTyping(receiverId);
  }
}