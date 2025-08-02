import 'package:flutter/material.dart';
import 'package:classmate/models/chat/message.dart';
import 'package:classmate/services/chat/chat_service.dart';
import 'package:classmate/services/chat/chat_graphql_service.dart';
import 'package:classmate/core/token_storage.dart';
import 'dart:io';

// Conversation model for the chat list
class Conversation {
  final String withUserId;
  final String withUserName;
  final String? withUserProfilePicture;
  final Message? lastMessage;
  final int unreadCount;
  final DateTime? lastActivity;

  Conversation({
    required this.withUserId,
    required this.withUserName,
    this.withUserProfilePicture,
    this.lastMessage,
    this.unreadCount = 0,
    this.lastActivity,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    final withUser = json['with_user'] ?? {};
    final lastMessage = json['last_message'];
    
    return Conversation(
      withUserId: withUser['id'] ?? '',
      withUserName: withUser['name'] ?? '',
      withUserProfilePicture: withUser['profile_picture'],
      lastMessage: lastMessage != null
          ? Message.fromJson(lastMessage)
          : null,
      unreadCount: json['unread_count'] ?? 0,
      lastActivity: lastMessage != null && lastMessage['createdAt'] != null
          ? DateTime.parse(lastMessage['createdAt'])
          : null,
    );
  }
}

enum ChatState { idle, loading, connected, error, disconnected }

class ChatController extends ChangeNotifier {
  final ChatService _chatService;
  final ChatGraphQLService _chatGraphQLService = ChatGraphQLService();
  final TokenStorage _tokenStorage = TokenStorage();
  
  final ValueNotifier<ChatState> _stateNotifier = ValueNotifier<ChatState>(ChatState.idle);
  final ValueNotifier<List<Message>> _messagesNotifier = ValueNotifier([]);
  final ValueNotifier<List<Conversation>> _conversationsNotifier = ValueNotifier([]);
  final ValueNotifier<Map<String, bool>> _typingStatusNotifier = ValueNotifier({});
  final ValueNotifier<Map<String, bool>> _onlineStatusNotifier = ValueNotifier({});
  final ValueNotifier<int> _unreadCountNotifier = ValueNotifier(0);
  
  String? errorMessage;
  String? currentUserId;
  String? currentUserProfilePicture;
  String? currentConversationUserId;
  bool _disposed = false;
  
  ChatController({
    required String userId,
    required String baseUrl,
    required String token,
    this.currentUserProfilePicture,
  }) : _chatService = ChatService(
          userId: userId,
          baseUrl: baseUrl,
          token: token,
        ) {
    currentUserId = userId;
    _initializeChat();
  }

  // Getters for accessing private notifiers
  ValueNotifier<ChatState> get stateNotifier => _stateNotifier;
  ValueNotifier<List<Message>> get messagesNotifier => _messagesNotifier;
  ValueNotifier<List<Conversation>> get conversationsNotifier => _conversationsNotifier;
  ValueNotifier<Map<String, bool>> get typingStatusNotifier => _typingStatusNotifier;
  ValueNotifier<Map<String, bool>> get onlineStatusNotifier => _onlineStatusNotifier;
  ValueNotifier<int> get unreadCountNotifier => _unreadCountNotifier;

  void _initializeChat() {
    _stateNotifier.value = ChatState.loading;
    
    // Listen to chat service changes
    _chatService.addListener(_onChatServiceUpdate);
    
    // Setup callback for message deletion events
    _chatService.onMessageDeleted = _handleSocketMessageDeletion;
    
    // Setup socket listeners
    _setupSocketListeners();
    
    _stateNotifier.value = ChatState.connected;
  }

  void _onChatServiceUpdate() {
    if (_disposed) return;
    // Update messages from chat service for current conversation
    if (currentConversationUserId != null) {
      final messages = _chatService.conversations[currentConversationUserId] ?? [];
      _messagesNotifier.value = List.from(messages); // Create new list to trigger UI update
    }
    
    // Update typing status
    _typingStatusNotifier.value = Map.from(_chatService.typingStatus);
    
    // Update conversations list
    _updateConversationsList();
    
    notifyListeners();
  }

  void _updateConversationsList() {
    if (_disposed) return;
    // This would typically update the conversations list based on recent messages
    // For now, we'll keep the existing conversations
    // TODO: Implement proper conversation list updates
  }

  void _updateConversationsListWithNewMessage(Message message) {
    if (_disposed) return;
    
    final conversationUserId = message.senderId == currentUserId 
        ? message.receiverId 
        : message.senderId;
    
    final currentConversations = List<Conversation>.from(_conversationsNotifier.value);
    
    // Find existing conversation
    final existingIndex = currentConversations.indexWhere(
      (conv) => conv.withUserId == conversationUserId
    );
    
    if (existingIndex != -1) {
      // Update existing conversation
      final existingConv = currentConversations[existingIndex];
      final updatedConv = Conversation(
        withUserId: existingConv.withUserId,
        withUserName: existingConv.withUserName,
        withUserProfilePicture: existingConv.withUserProfilePicture,
        lastMessage: message,
        unreadCount: message.receiverId == currentUserId 
            ? existingConv.unreadCount + 1 
            : existingConv.unreadCount,
        lastActivity: message.createdAt,
      );
      
      currentConversations[existingIndex] = updatedConv;
      
      // Move to top of list
      currentConversations.removeAt(existingIndex);
      currentConversations.insert(0, updatedConv);
    } else {
      // Create new conversation (this would need user info from backend)
      // For now, we'll reload conversations to get proper user info
      loadConversations();
      return;
    }
    
    // Sort by last activity (most recent first)
    currentConversations.sort((a, b) => 
      (b.lastActivity ?? DateTime(0)).compareTo(a.lastActivity ?? DateTime(0))
    );
    
    _conversationsNotifier.value = currentConversations;
  }

  void _updateConversationAfterMessageDeletion(Message deletedMessage, List<Message> remainingMessages) {
     if (_disposed || currentConversationUserId == null) return;
     
     final currentConversations = List<Conversation>.from(_conversationsNotifier.value);
     
     // Find the conversation that needs updating
     final existingIndex = currentConversations.indexWhere(
       (conv) => conv.withUserId == currentConversationUserId
     );
     
     if (existingIndex != -1) {
       final existingConv = currentConversations[existingIndex];
       
       // Check if the deleted message was the last message in this conversation
       if (existingConv.lastMessage?.id == deletedMessage.id) {
         // Find the new last message from remaining messages
         Message? newLastMessage;
         if (remainingMessages.isNotEmpty) {
           // Sort by creation time and get the most recent
           final sortedMessages = List<Message>.from(remainingMessages)
             ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
           newLastMessage = sortedMessages.first;
         }
         
         // Update the conversation with new last message
         final updatedConv = Conversation(
           withUserId: existingConv.withUserId,
           withUserName: existingConv.withUserName,
           withUserProfilePicture: existingConv.withUserProfilePicture,
           lastMessage: newLastMessage,
           unreadCount: existingConv.unreadCount,
           lastActivity: newLastMessage?.createdAt,
         );
         
         currentConversations[existingIndex] = updatedConv;
         
         // Re-sort conversations by last activity
         currentConversations.sort((a, b) => 
           (b.lastActivity ?? DateTime(0)).compareTo(a.lastActivity ?? DateTime(0))
         );
         
         _conversationsNotifier.value = currentConversations;
         print('🗑️ DELETE DEBUG: Updated conversation list with new last message');
       }
     }
   }

   void _handleSocketMessageDeletion(String messageId, String conversationUserId) {
     if (_disposed) return;
     
     print('🗑️ SOCKET DELETE DEBUG: Handling deletion of message $messageId in conversation $conversationUserId');
     
     // Get the remaining messages for this conversation
     final remainingMessages = _chatService.conversations[conversationUserId] ?? [];
     
     // Update the conversation list to reflect the new last message
     final currentConversations = List<Conversation>.from(_conversationsNotifier.value);
     final existingIndex = currentConversations.indexWhere(
       (conv) => conv.withUserId == conversationUserId
     );
     
     if (existingIndex != -1) {
       final existingConv = currentConversations[existingIndex];
       
       // Check if the deleted message was the last message in this conversation
       if (existingConv.lastMessage?.id == messageId) {
         // Find the new last message from remaining messages
         Message? newLastMessage;
         if (remainingMessages.isNotEmpty) {
           // Sort by creation time and get the most recent
           final sortedMessages = List<Message>.from(remainingMessages)
             ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
           newLastMessage = sortedMessages.first;
         }
         
         // Update the conversation with new last message
         final updatedConv = Conversation(
           withUserId: existingConv.withUserId,
           withUserName: existingConv.withUserName,
           withUserProfilePicture: existingConv.withUserProfilePicture,
           lastMessage: newLastMessage,
           unreadCount: existingConv.unreadCount,
           lastActivity: newLastMessage?.createdAt,
         );
         
         currentConversations[existingIndex] = updatedConv;
         
         // Re-sort conversations by last activity
         currentConversations.sort((a, b) => 
           (b.lastActivity ?? DateTime(0)).compareTo(a.lastActivity ?? DateTime(0))
         );
         
         _conversationsNotifier.value = currentConversations;
         print('🗑️ SOCKET DELETE DEBUG: Updated conversation list after socket deletion');
       }
     }
     
     // Also update the current messages if we're viewing this conversation
     if (currentConversationUserId == conversationUserId) {
       final currentMessages = List<Message>.from(_messagesNotifier.value);
       currentMessages.removeWhere((m) => m.id == messageId);
       _messagesNotifier.value = currentMessages;
       print('🗑️ SOCKET DELETE DEBUG: Updated current messages view');
     }
   }

  // Set current conversation and load messages
  void setCurrentConversation(String userId) {
    currentConversationUserId = userId;
    
    // Always load messages from database to ensure persistence
    loadMessages(userId);
  }

  Future<void> loadMessages(String userId) async {
    try {
      final dbMessages = await _chatGraphQLService.getConversation(
        withUserId: userId,
        page: 1,
        limit: 50,
      );
      
      if (!_disposed && dbMessages != null) {
        // Get existing in-memory messages
        final existingMessages = _chatService.conversations[userId] ?? [];
        
        // Merge database messages with in-memory messages
        // Remove duplicates by checking message IDs
        final allMessages = <Message>[];
        final messageIds = <String>{};
        
        // Add database messages first
        for (final message in dbMessages) {
          if (!messageIds.contains(message.id)) {
            allMessages.add(message);
            messageIds.add(message.id);
          }
        }
        
        // Add any new in-memory messages not in database
        for (final message in existingMessages) {
          if (!messageIds.contains(message.id)) {
            allMessages.add(message);
            messageIds.add(message.id);
          }
        }
        
        // Sort messages by createdAt timestamp
         allMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        
        // Store merged messages in chat service
        _chatService.conversations[userId] = allMessages;
        
        // Update UI if this is the current conversation
        if (!_disposed && currentConversationUserId == userId) {
          _messagesNotifier.value = List.from(allMessages);
        }
      } else if (!_disposed) {
        // If no database messages, use existing in-memory messages
        final existingMessages = _chatService.conversations[userId] ?? [];
        if (currentConversationUserId == userId) {
          _messagesNotifier.value = List.from(existingMessages);
        }
      }
    } catch (e) {
      print('Error loading messages: $e');
      if (!_disposed) {
        // On error, use existing in-memory messages if available
        final existingMessages = _chatService.conversations[userId] ?? [];
        if (currentConversationUserId == userId) {
          _messagesNotifier.value = List.from(existingMessages);
        }
      }
    }
  }

  // Clear current conversation
  void clearCurrentConversation() {
    if (_disposed) return;
    currentConversationUserId = null;
    _messagesNotifier.value = [];
  }

  // Helper method to determine if a message is from the current user
  bool isMessageFromCurrentUser(Message message) {
    if (currentUserId == null) return false;
    
    // Primary comparison: normalize both IDs by trimming whitespace
    final normalizedCurrentUserId = currentUserId!.trim();
    final normalizedSenderId = message.senderId.trim();
    
    if (normalizedSenderId == normalizedCurrentUserId) {
      return true;
    }
    
    // Fallback: check if this is a temporary message (which we created locally)
    if (message.id.startsWith('temp_')) {
      return true;
    }
    
    // Additional fallback: check if message receiver is the conversation partner
    // If we're in a conversation and the message receiver is the other user,
    // then this message must be from the current user
    if (currentConversationUserId != null && 
        message.receiverId.trim() == currentConversationUserId!.trim()) {
      return true;
    }
    
    return false;
  }

  void _setupSocketListeners() {
    // Listen for new messages
    _chatService.socket.on('message', (data) {
      if (_disposed) return;
      
      final message = Message.fromJson(data);
      
      // Update conversations list immediately
      _updateConversationsListWithNewMessage(message);
      
      // If this message is for the current conversation, update the UI immediately
      if (currentConversationUserId != null) {
        final conversationUserId = isMessageFromCurrentUser(message)
            ? message.receiverId 
            : message.senderId;
        
        if (conversationUserId == currentConversationUserId) {
          final currentMessages = List<Message>.from(_messagesNotifier.value);
          
          // Remove any temporary message with similar content and timestamp
          if (isMessageFromCurrentUser(message)) {
            currentMessages.removeWhere((m) => 
              m.id.startsWith('temp_') && 
              m.content == message.content &&
              m.senderId == message.senderId &&
              m.receiverId == message.receiverId
            );
          }
          
          // Check if message already exists to avoid duplicates
          if (!currentMessages.any((m) => m.id == message.id)) {
            currentMessages.add(message);
            currentMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
            _messagesNotifier.value = currentMessages;
          }
        }
      }
    });

    // User online/offline status
    _chatService.socket.on('userOnline', (data) {
      if (_disposed) return;
      final userId = data['userId'];
      final onlineUsers = List<String>.from(data['onlineUsers'] ?? []);
      
      final newStatus = Map<String, bool>.from(_onlineStatusNotifier.value);
      newStatus[userId] = true;
      
      // Update all online users
      for (String user in onlineUsers) {
        newStatus[user] = true;
      }
      
      _onlineStatusNotifier.value = newStatus;
    });

    _chatService.socket.on('userOffline', (data) {
      if (_disposed) return;
      final userId = data['userId'];
      final newStatus = Map<String, bool>.from(_onlineStatusNotifier.value);
      newStatus[userId] = false;
      _onlineStatusNotifier.value = newStatus;
    });

    // Message delivery and read receipts
    _chatService.socket.on('messageDelivered', (data) {
      if (_disposed) return;
      _updateMessageStatus(data['messageId'], delivered: true);
    });

    _chatService.socket.on('messageRead', (data) {
      if (_disposed) return;
      _updateMessageStatus(data['messageId'], read: true);
    });

    // Call events
    _chatService.socket.on('incomingCall', (data) {
      if (_disposed) return;
      // Handle incoming call
      _handleIncomingCall(data);
    });

    _chatService.socket.on('callAccepted', (data) {
      if (_disposed) return;
      // Handle call accepted
      _handleCallAccepted(data);
    });

    _chatService.socket.on('callRejected', (data) {
      if (_disposed) return;
      // Handle call rejected
      _handleCallRejected(data);
    });

    _chatService.socket.on('callEnded', (data) {
      if (_disposed) return;
      // Handle call ended
      _handleCallEnded(data);
    });
  }

  // Message operations
  Future<void> sendMessage({
    required String receiverId,
    required String content,
    String type = 'text',
    File? file,
    String? replyToId,
    bool forward = false,
    String? forwardFromId,
  }) async {
    try {

      // Create a temporary message for immediate UI update
      final tempMessage = Message(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        senderId: currentUserId!,
        receiverId: receiverId,
        content: content,
        messageType: type,
        fileUrl: file != null ? 'file://${file.path}' : null, // Local file path for immediate preview
        fileName: file?.path.split('/').last,
        fileSize: file != null ? await file.length() : null,
        fileType: file != null ? _getFileType(file.path) : null,
        reactions: [],
        forwarded: forward,
        read: false,
        delivered: false,
        edited: false,
        createdAt: DateTime.now(),
        replyTo: replyToId,
        forwardedFrom: forwardFromId,
      );
      
      // Add message to UI immediately if it's for current conversation
      if (currentConversationUserId == receiverId) {
        final currentMessages = List<Message>.from(_messagesNotifier.value);
        currentMessages.add(tempMessage);
        currentMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        _messagesNotifier.value = currentMessages;
      }
      
      // Update conversations list with the new message
      _updateConversationsListWithNewMessage(tempMessage);
      
      if (file != null) {
        // Send file message via socket
        _chatService.sendFileMessage(
          receiverId: receiverId,
          content: content,
          file: file,
          replyToId: replyToId,
        );
      } else {
        // Send text message via socket
        _chatService.sendMessage(
          receiverId: receiverId,
          content: content,
          type: type,
          replyToId: replyToId,
          forward: forward,
          forwardFromId: forwardFromId,
        );
      }
    } catch (e) {
      errorMessage = e.toString();
      _stateNotifier.value = ChatState.error;
    }
  }

  Future<void> editMessage(String messageId, String newContent) async {
    try {
      _chatService.editMessage(messageId, newContent);
    } catch (e) {
      errorMessage = e.toString();
    }
  }

  Future<void> deleteMessage(String messageId, {bool forEveryone = true}) async {
    try {
      print('🗑️ DELETE DEBUG: Deleting message $messageId for everyone');
      
      // Check if this is a temporary message (not yet sent to server)
      final isTemporaryMessage = messageId.startsWith('temp_');
      
      if (!isTemporaryMessage) {
        // Delete via Socket.IO for real-time updates (only for server messages)
        _chatService.deleteMessage(messageId, forEveryone: true);
        
        // Also delete via GraphQL for persistence (only for server messages)
        final success = await _chatGraphQLService.deleteMessage(messageId, forEveryone: true);
        print('🗑️ DELETE DEBUG: GraphQL deletion success: $success');
        
        if (!success) {
          print('🗑️ DELETE WARNING: GraphQL deletion failed, but continuing with local deletion');
        }
      } else {
        print('🗑️ DELETE DEBUG: Skipping server deletion for temporary message');
      }
      
      // Update local UI immediately for better UX - always remove message completely
      if (currentConversationUserId != null) {
        final currentMessages = List<Message>.from(_messagesNotifier.value);
        final deletedMessage = currentMessages.firstWhere((m) => m.id == messageId, orElse: () => throw StateError('Message not found'));
        currentMessages.removeWhere((m) => m.id == messageId);
        print('🗑️ DELETE DEBUG: Removed message from UI');
        _messagesNotifier.value = currentMessages;
        
        // Also remove from the service's local conversation cache
        _chatService.conversations[currentConversationUserId]?.removeWhere((m) => m.id == messageId);
        
        // Update conversations list if the deleted message was the last message
        _updateConversationAfterMessageDeletion(deletedMessage, currentMessages);
      }
      
    } catch (e) {
      print('🗑️ DELETE ERROR: $e');
      errorMessage = e.toString();
    }
  }

  // Delete entire conversation
  Future<void> deleteConversation(String withUserId) async {
    try {
      // Remove conversation from local list immediately for better UX
      final currentConversations = List<Conversation>.from(_conversationsNotifier.value);
      currentConversations.removeWhere((conv) => conv.withUserId == withUserId);
      _conversationsNotifier.value = currentConversations;
      
      // Clear messages from memory
      _chatService.conversations.remove(withUserId);
      
      // If this was the current conversation, clear it
      if (currentConversationUserId == withUserId) {
        clearCurrentConversation();
      }
      
      // Delete from backend via Socket.IO
      _chatService.deleteConversation(withUserId);
      
      // Also delete via GraphQL for persistence
      final success = await _chatGraphQLService.deleteConversation(withUserId);
      if (!success) {
        print('Warning: Failed to delete conversation from backend');
        // Note: We don't revert the local deletion as the user expects it to be deleted
        // The backend deletion failure should be handled gracefully
      }
      
    } catch (e) {
      errorMessage = e.toString();
      print('Error deleting conversation: $e');
    }
  }

  Future<void> reactToMessage(String messageId, String reaction) async {
    try {
      _chatService.reactToMessage(messageId, reaction);
    } catch (e) {
      errorMessage = e.toString();
    }
  }

  Future<void> forwardMessage(String messageId, List<String> toUserIds) async {
    try {
      _chatService.forwardMessage(messageId, toUserIds);
    } catch (e) {
      errorMessage = e.toString();
    }
  }

  // Conversation operations
  Future<void> loadConversation(String withUserId, {int page = 1, int limit = 20}) async {
    try {
      if (_disposed) return;
      _stateNotifier.value = ChatState.loading;
      currentConversationUserId = withUserId;
      
      // Load from GraphQL first for history
      final messages = await _chatGraphQLService.getConversation(
        withUserId: withUserId,
        page: page,
        limit: limit,
      );
      
      if (!_disposed && messages != null) {
        _messagesNotifier.value = messages;
      }
      
      // Also request via socket for real-time updates
      if (!_disposed) {
        _chatService.getConversation(withUserId, page, limit);
        _stateNotifier.value = ChatState.connected;
      }
    } catch (e) {
      if (!_disposed) {
        errorMessage = e.toString();
        _stateNotifier.value = ChatState.error;
      }
    }
  }

  Future<void> loadConversations() async {
    try {
      final conversations = await _chatGraphQLService.getConversations();
      if (!_disposed && conversations != null) {
        _conversationsNotifier.value = conversations;
      }
    } catch (e) {
      if (!_disposed) {
        errorMessage = e.toString();
      }
    }
  }

  Future<void> markMessagesAsRead(String withUserId) async {
    try {
      await _chatGraphQLService.markMessagesAsRead(withUserId);
      _chatService.markMessagesAsRead(withUserId);
    } catch (e) {
      errorMessage = e.toString();
    }
  }

  Future<List<Message>?> searchMessages(String query, {String? withUserId}) async {
    try {
      return await _chatGraphQLService.searchMessages(query, withUserId: withUserId);
    } catch (e) {
      errorMessage = e.toString();
      return null;
    }
  }

  String _getFileType(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return 'image/$extension';
      case 'mp4':
      case 'mov':
      case 'avi':
      case 'webm':
        return 'video/$extension';
      case 'mp3':
      case 'wav':
      case 'ogg':
      case 'm4a':
        return 'audio/$extension';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
      case 'docx':
        return 'application/msword';
      case 'txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }

  Future<void> loadUnreadMessages() async {
    try {
      final unreadData = await _chatGraphQLService.getUnreadMessages();
      if (!_disposed && unreadData != null) {
        _unreadCountNotifier.value = unreadData['count'] ?? 0;
      }
    } catch (e) {
      if (!_disposed) {
        errorMessage = e.toString();
      }
    }
  }

  // Typing indicators
  void startTyping(String toUserId) {
    _chatService.startTyping(toUserId);
  }

  void stopTyping(String toUserId) {
    _chatService.stopTyping(toUserId);
  }

  // Call operations
  void initiateCall(String toUserId, String callType, dynamic signalData) {
    _chatService.initiateCall(toUserId, callType, signalData);
  }

  void answerCall(String toUserId, dynamic signalData) {
    _chatService.answerCall(toUserId, signalData);
  }

  void rejectCall(String toUserId) {
    _chatService.rejectCall(toUserId);
  }

  void endCall(String toUserId) {
    _chatService.endCall(toUserId);
  }

  // Helper methods
  void _updateMessageStatus(String messageId, {bool? delivered, bool? read}) {
    if (_disposed) return;
    final currentMessages = List<Message>.from(_messagesNotifier.value);
    final index = currentMessages.indexWhere((m) => m.id == messageId);
    
    if (index != -1) {
      currentMessages[index] = currentMessages[index].copyWith(
        delivered: delivered ?? currentMessages[index].delivered,
        read: read ?? currentMessages[index].read,
        deliveredAt: delivered == true ? DateTime.now() : currentMessages[index].deliveredAt,
        readAt: read == true ? DateTime.now() : currentMessages[index].readAt,
      );
      _messagesNotifier.value = currentMessages;
    }
  }

  void _handleIncomingCall(Map<String, dynamic> data) {
    // Implement incoming call handling
    // This could show a call dialog or notification
  }

  void _handleCallAccepted(Map<String, dynamic> data) {
    // Implement call accepted handling
  }

  void _handleCallRejected(Map<String, dynamic> data) {
    // Implement call rejected handling
  }

  void _handleCallEnded(Map<String, dynamic> data) {
    // Implement call ended handling
  }

  bool isUserOnline(String userId) {
    return _onlineStatusNotifier.value[userId] ?? false;
  }

  bool isUserTyping(String userId) {
    return _typingStatusNotifier.value[userId] ?? false;
  }

  @override
  void dispose() {
    _disposed = true;
    _chatService.removeListener(_onChatServiceUpdate);
    _chatService.disconnect();
    _stateNotifier.dispose();
    _messagesNotifier.dispose();
    _conversationsNotifier.dispose();
    _typingStatusNotifier.dispose();
    _onlineStatusNotifier.dispose();
    _unreadCountNotifier.dispose();
    super.dispose();
  }
}