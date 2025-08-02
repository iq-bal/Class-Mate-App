import 'package:classmate/models/chat/message.dart';
import 'package:classmate/controllers/chat/chat_controller.dart';
import 'package:classmate/core/dio_client.dart';
import 'package:classmate/core/token_storage.dart';
import 'package:classmate/config/app_config.dart';

class ChatGraphQLService {
  final DioClient _dioClient = DioClient();
  final TokenStorage _tokenStorage = TokenStorage();

  // Get conversation history
  Future<List<Message>?> getConversation({
    required String withUserId,
    int page = 1,
    int limit = 20,
  }) async {
    const String query = r'''
      query GetConversation($withUserId: ID!, $page: Int, $limit: Int) {
        conversation(with_user_id: $withUserId, page: $page, limit: $limit) {
          id
          content
          message_type
          file_url
          file_name
          createdAt
          sender_id {
            id
            name
            profile_picture
          }
          receiver_id {
            id
            name
            profile_picture
          }
          reactions {
            reaction
            user_id {
              id
              name
              profile_picture
            }
            created_at
          }
          reply_to {
            id
            content
            message_type
            sender_id {
              id
              name
              profile_picture
            }
          }
          forwarded
          forwarded_from {
            id
            name
          }
          read
          delivered
          edited
          edited_at
        }
      }
    ''';

    try {
      final response = await _dioClient.getDio(AppConfig.graphqlServer).post(
        '/',
        data: {
          'query': query,
          'variables': {
            'withUserId': withUserId,
            'page': page,
            'limit': limit,
          },
        },
      );
      
      final result = response.data;

      if (result != null && result['data'] != null && result['data']['conversation'] != null) {
        final List<dynamic> messagesJson = result['data']['conversation'];
        
        final messages = messagesJson.map((json) {
          return Message.fromJson(json);
        }).toList();
        
        return messages;
      }
      return [];
    } catch (e) {
      print('Error fetching conversation: $e');
      return null;
    }
  }

  // Get all conversations
  Future<List<Conversation>?> getConversations() async {
    const String query = r'''
      query GetConversations {
        conversations {
          total
          conversations {
            with_user {
              id
              name
              profile_picture
            }
            unread_count
            last_message {
              id
              content
              message_type
              createdAt
              sender_id {
                name
              }
            }
          }
        }
      }
    ''';

    try {
      final response = await _dioClient.getDio(AppConfig.graphqlServer).post(
        '/',
        data: {'query': query},
      );
      
      final result = response.data;
      print('Conversations response: $result'); // Debug log

      if (result != null && result['data'] != null && result['data']['conversations'] != null) {
        final List<dynamic> conversationsJson = result['data']['conversations']['conversations'];
        print('Conversations JSON: $conversationsJson'); // Debug log
        return conversationsJson.map((json) => Conversation.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching conversations: $e');
      return null;
    }
  }

  // Get unread messages
  Future<Map<String, dynamic>?> getUnreadMessages() async {
    const String query = r'''
      query GetUnreadMessages {
        unreadMessageCount
        unreadMessages {
          id
          content
          message_type
          createdAt
          sender_id {
            id
            name
            profile_picture
          }
        }
      }
    ''';

    try {
      final response = await _dioClient.getDio(AppConfig.graphqlServer).post(
        '/',
        data: {'query': query},
      );
      
      final result = response.data;
      print('Unread messages response: $result'); // Debug log

      if (result != null && result['data'] != null) {
        print('Unread messages data: ${result['data']}'); // Debug log
        return {
          'count': result['data']['unreadMessageCount'] ?? 0,
          'messages': (result['data']['unreadMessages'] as List?)
              ?.map((json) => Message.fromJson(json))
              .toList() ?? [],
        };
      }
      return null;
    } catch (e) {
      print('Error fetching unread messages: $e');
      return null;
    }
  }

  // Search messages
  Future<List<Message>?> searchMessages(String query, {String? withUserId}) async {
    const String searchQuery = r'''
      query SearchMessages($query: String!, $withUserId: ID) {
        searchMessages(query: $query, with_user_id: $withUserId) {
          id
          content
          message_type
          createdAt
          sender_id {
            id
            name
            profile_picture
          }
          receiver_id {
            id
            name
            profile_picture
          }
        }
      }
    ''';

    try {
      final response = await _dioClient.getDio(AppConfig.graphqlServer).post(
        '/',
        data: {
          'query': searchQuery,
          'variables': {
            'query': query,
            if (withUserId != null) 'withUserId': withUserId,
          },
        },
      );
      
      final result = response.data;

      if (result != null && result['data'] != null && result['data']['searchMessages'] != null) {
        final List<dynamic> messagesJson = result['data']['searchMessages'];
        return messagesJson.map((json) => Message.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error searching messages: $e');
      return null;
    }
  }

  // Send message
  Future<Message?> sendMessage({
    required String receiverId,
    required String content,
    String messageType = 'text',
    String? replyToId,
  }) async {
    const String mutation = r'''
      mutation SendMessage($messageInput: MessageInput!) {
        sendMessage(messageInput: $messageInput) {
          id
          content
          message_type
          file_url
          createdAt
          sender_id {
            id
            name
            profile_picture
          }
          receiver_id {
            id
            name
            profile_picture
          }
        }
      }
    ''';

    try {
      final variables = {
        'messageInput': {
          'receiver_id': receiverId,
          'content': content,
          'message_type': messageType,
          if (replyToId != null) 'reply_to': replyToId,
        },
      };

      final response = await _dioClient.getDio(AppConfig.graphqlServer).post(
        '/',
        data: {
          'query': mutation,
          'variables': variables,
        },
      );
      
      final result = response.data;

      if (result != null && result['data'] != null && result['data']['sendMessage'] != null) {
        return Message.fromJson(result['data']['sendMessage']);
      }
      return null;
    } catch (e) {
      print('Error sending message: $e');
      return null;
    }
  }

  // Mark messages as read
  Future<bool> markMessagesAsRead(String withUserId) async {
    const String mutation = r'''
      mutation MarkMessagesAsRead($withUserId: ID!) {
        markMessagesAsRead(with_user_id: $withUserId)
      }
    ''';

    try {
      final response = await _dioClient.getDio(AppConfig.graphqlServer).post(
        '/',
        data: {
          'query': mutation,
          'variables': {'withUserId': withUserId},
        },
      );
      
      final result = response.data;

      return result != null && result['data'] != null && result['data']['markMessagesAsRead'] == true;
    } catch (e) {
      print('Error marking messages as read: $e');
      return false;
    }
  }

  // Edit message
  Future<Message?> editMessage(String messageId, String newContent) async {
    const String mutation = r'''
      mutation EditMessage($messageId: ID!, $newContent: String!) {
        editMessage(message_id: $messageId, new_content: $newContent) {
          id
          content
          edited
          edited_at
        }
      }
    ''';

    try {
      final response = await _dioClient.getDio(AppConfig.graphqlServer).post(
        '/',
        data: {
          'query': mutation,
          'variables': {
            'messageId': messageId,
            'newContent': newContent,
          },
        },
      );
      
      final result = response.data;

      if (result != null && result['data'] != null && result['data']['editMessage'] != null) {
        return Message.fromJson(result['data']['editMessage']);
      }
      return null;
    } catch (e) {
      print('Error editing message: $e');
      return null;
    }
  }

  // Delete message
  Future<bool> deleteMessage(String messageId, {bool forEveryone = true}) async {
    const String mutation = r'''
      mutation DeleteMessage($messageId: ID!, $forEveryone: Boolean) {
        deleteMessage(message_id: $messageId, for_everyone: $forEveryone)
      }
    ''';

    try {
      final response = await _dioClient.getDio(AppConfig.graphqlServer).post(
        '/',
        data: {
          'query': mutation,
          'variables': {
            'messageId': messageId,
            'forEveryone': forEveryone,
          },
        },
      );
      
      final result = response.data;

      return result != null && result['data'] != null && result['data']['deleteMessage'] == true;
    } catch (e) {
      print('Error deleting message: $e');
      return false;
    }
  }

  // Delete entire conversation
  Future<bool> deleteConversation(String withUserId) async {
    const String mutation = r'''
      mutation DeleteConversation($withUserId: ID!) {
        deleteConversation(with_user_id: $withUserId)
      }
    ''';

    try {
      final response = await _dioClient.getDio(AppConfig.graphqlServer).post(
        '/',
        data: {
          'query': mutation,
          'variables': {
            'withUserId': withUserId,
          },
        },
      );
      
      final result = response.data;

      // Check for GraphQL errors
      if (result != null && result['errors'] != null) {
        print('GraphQL errors in delete conversation: ${result['errors']}');
        return false;
      }

      // The backend returns: {"data": {"deleteConversation": true}}
      if (result != null && result['data'] != null && result['data']['deleteConversation'] == true) {
        return true;
      }
      
      return false;
    } catch (e) {
      print('Error deleting conversation: $e');
      return false;
    }
  }

  // React to message
  Future<Message?> reactToMessage(String messageId, String reaction) async {
    const String mutation = r'''
      mutation ReactToMessage($reactionInput: MessageReactionInput!) {
        reactToMessage(reactionInput: $reactionInput) {
          id
          reactions {
            reaction
            user_id {
              id
              name
              profile_picture
            }
            created_at
          }
        }
      }
    ''';

    try {
      final response = await _dioClient.getDio(AppConfig.graphqlServer).post(
        '/',
        data: {
          'query': mutation,
          'variables': {
            'reactionInput': {
              'message_id': messageId,
              'reaction': reaction,
            },
          },
        },
      );
      
      final result = response.data;

      if (result != null && result['data'] != null && result['data']['reactToMessage'] != null) {
        return Message.fromJson(result['data']['reactToMessage']);
      }
      
      return null;
    } catch (e) {
      print('Error reacting to message: $e');
      return null;
    }
  }

  // Forward message
  Future<List<Message>?> forwardMessage(String messageId, List<String> toUserIds) async {
    const String mutation = r'''
      mutation ForwardMessage($messageId: ID!, $toUserIds: [ID!]!) {
        forwardMessage(message_id: $messageId, to_user_ids: $toUserIds) {
          id
          content
          forwarded
          forwarded_from {
            id
            name
          }
          receiver_id {
            id
            name
          }
        }
      }
    ''';

    try {
      final response = await _dioClient.getDio(AppConfig.graphqlServer).post(
        '/',
        data: {
          'query': mutation,
          'variables': {
            'messageId': messageId,
            'toUserIds': toUserIds,
          },
        },
      );
      
      final result = response.data;

      if (result != null && result['data'] != null && result['data']['forwardMessage'] != null) {
        final List<dynamic> messagesJson = result['data']['forwardMessage'];
        return messagesJson.map((json) => Message.fromJson(json)).toList();
      }
      return null;
    } catch (e) {
      print('Error forwarding message: $e');
      return null;
    }
  }

  // Search users
  Future<List<SearchUser>?> searchUsers(String query) async {
    const String searchQuery = r'''
      query SearchUsers($query: String!) {
        searchUsers(query: $query) {
          id
          name
          email
          profile_picture
          role
        }
      }
    ''';

    try {
      final response = await _dioClient.getDio(AppConfig.graphqlServer).post(
        '/',
        data: {
          'query': searchQuery,
          'variables': {
            'query': query,
          },
        },
      );
      
      final result = response.data;

      if (result != null && result['data'] != null && result['data']['searchUsers'] != null) {
        final List<dynamic> usersJson = result['data']['searchUsers'];
        return usersJson.map((json) => SearchUser.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error searching users: $e');
      return null;
    }
  }
}

class SearchUser {
  final String id;
  final String name;
  final String? email;
  final String? profilePicture;
  final String? role;

  SearchUser({
    required this.id,
    required this.name,
    this.email,
    this.profilePicture,
    this.role,
  });

  factory SearchUser.fromJson(Map<String, dynamic> json) {
    return SearchUser(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'],
      profilePicture: json['profile_picture'],
      role: json['role'],
    );
  }
}