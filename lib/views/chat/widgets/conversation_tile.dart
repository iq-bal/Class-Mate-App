import 'package:flutter/material.dart';
import 'package:classmate/controllers/chat/chat_controller.dart';
import 'package:classmate/views/chat/chat_screen_view.dart';
import 'package:classmate/config/app_config.dart';
import 'package:intl/intl.dart';

class ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final ChatController chatController;
  final VoidCallback? onTap;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.chatController,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Dismissible(
        key: Key('conversation_${conversation.withUserId}'),
        direction: DismissDirection.endToStart,
        background: Container(
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(
            Icons.delete,
            color: Colors.white,
            size: 28,
          ),
        ),
        confirmDismiss: (direction) async {
          return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete Conversation'),
              content: Text('Are you sure you want to delete the conversation with ${conversation.withUserName}?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );
        },
        onDismissed: (direction) {
          chatController.deleteConversation(conversation.withUserId);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Conversation with ${conversation.withUserName} deleted'),
              backgroundColor: Colors.red,
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: conversation.withUserProfilePicture != null
                ? NetworkImage('${AppConfig.imageServer}${conversation.withUserProfilePicture}')
                : const AssetImage('assets/images/avatar.png') as ImageProvider,
              backgroundColor: Colors.grey[300],
            ),
            // Online status indicator
            ValueListenableBuilder<Map<String, bool>>(
              valueListenable: chatController.onlineStatusNotifier,
              builder: (context, onlineStatus, _) {
                final isOnline = onlineStatus[conversation.withUserId] ?? false;
                if (!isOnline) return const SizedBox.shrink();
                
                return Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    width: 14,
                    height: 14,
                  ),
                );
              },
            ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                conversation.withUserName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (conversation.lastMessage != null)
              Text(
                _formatTime(conversation.lastMessage!.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
        subtitle: Row(
          children: [
            // Typing indicator
            ValueListenableBuilder<Map<String, bool>>(
              valueListenable: chatController.typingStatusNotifier,
              builder: (context, typingStatus, _) {
                final isTyping = typingStatus[conversation.withUserId] ?? false;
                if (isTyping) {
                  return Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 12,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildTypingDot(0),
                            _buildTypingDot(1),
                            _buildTypingDot(2),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'typing...',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  );
                }
                
                // Last message
                if (conversation.lastMessage != null) {
                  return Expanded(
                    child: Text(
                      _getMessagePreview(conversation.lastMessage!),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }
                
                return const Text(
                  'No messages yet',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                );
              },
            ),
          ],
        ),
        trailing: conversation.unreadCount > 0
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  conversation.unreadCount > 99 ? '99+' : conversation.unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
        onTap: onTap ?? () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreenView(
                withUserId: conversation.withUserId,
                withUserName: conversation.withUserName,
                withUserProfilePicture: conversation.withUserProfilePicture,
                currentUserProfilePicture: chatController.currentUserProfilePicture,
                chatController: chatController,
              ),
            ),
          );
        },
      ),
        ),
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 200)),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.5 + (value * 0.5),
          child: Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.blue[600],
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  String _getMessagePreview(dynamic lastMessage) {
    if (lastMessage.messageType == 'text') {
      return lastMessage.content;
    } else if (lastMessage.messageType == 'image') {
      return '📷 Photo';
    } else if (lastMessage.messageType == 'file') {
      return '📎 File';
    } else if (lastMessage.messageType == 'voice') {
      return '🎵 Voice message';
    } else if (lastMessage.messageType == 'video') {
      return '🎥 Video';
    }
    return lastMessage.content;
  }
}