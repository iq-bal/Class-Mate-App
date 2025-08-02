import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:classmate/models/chat/message.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final String? currentUserProfilePicture;
  final String? otherUserProfilePicture;
  final Function(String)? onReact;
  final VoidCallback? onReply;
  final VoidCallback? onForward;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onDeleteForEveryone;
  final Message? repliedMessage;
  final String? repliedToUserName;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.currentUserProfilePicture,
    this.otherUserProfilePicture,
    this.onReact,
    this.onReply,
    this.onForward,
    this.onEdit,
    this.onDelete,
    this.onDeleteForEveryone,
    this.repliedMessage,
    this.repliedToUserName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ..._buildSenderAvatar(),
          Flexible(
            child: GestureDetector(
              onLongPress: () => _showMessageOptions(context),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isMe ? Colors.blue[600] : Colors.grey[200],
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(4),
                    bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Reply to message (if any)
                    if (message.replyTo != null || repliedMessage != null) _buildReplyPreview(),
                    
                    // Message content
                    _buildMessageContent(),
                    
                    // Message reactions
                    if (message.reactions.isNotEmpty) _buildReactionsDisplay(),
                    
                    // Message time and status
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(message.createdAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: isMe ? Colors.white70 : Colors.grey[600],
                          ),
                        ),
                        if (isMe) ..._buildMessageStatus(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isMe) ..._buildSenderAvatar(),
        ],
      ),
    );
  }

  List<Widget> _buildSenderAvatar() {
    final profilePicture = isMe ? currentUserProfilePicture : otherUserProfilePicture;
    
    return [
      const SizedBox(width: 8),
      CircleAvatar(
        radius: 16,
        backgroundImage: profilePicture != null
            ? NetworkImage('http://localhost:4001$profilePicture')
            : const AssetImage('assets/images/avatar.png') as ImageProvider,
        backgroundColor: Colors.grey,
      ),
    ];
  }

  Widget _buildReplyPreview() {
    // Always show reply preview if there's a replyTo field
    if (repliedMessage == null && message.replyTo == null) {
      return const SizedBox.shrink();
    }
    
    if (repliedMessage == null) {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[700] : Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
          border: Border(
            left: BorderSide(
              color: isMe ? Colors.white : Colors.blue,
              width: 2,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Replying to ${repliedToUserName ?? 'someone'}',
              style: TextStyle(
                fontSize: 10,
                color: isMe ? Colors.white70 : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Original message', // Fallback when replied message is not available
              style: TextStyle(
                fontSize: 12,
                color: isMe ? Colors.white : Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isMe ? Colors.blue[700] : Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: isMe ? Colors.white : Colors.blue,
            width: 2,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Replying to ${repliedToUserName ?? 'Unknown'}',
            style: TextStyle(
              fontSize: 10,
              color: isMe ? Colors.white70 : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _getRepliedMessagePreview(),
            style: TextStyle(
              fontSize: 12,
              color: isMe ? Colors.white : Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _getRepliedMessagePreview() {
    if (repliedMessage == null) return 'Original message';
    
    switch (repliedMessage!.messageType) {
      case 'text':
        return repliedMessage!.content;
      case 'image':
        return '📷 Image${repliedMessage!.content.isNotEmpty ? ': ${repliedMessage!.content}' : ''}';
      case 'voice':
        return '🎤 Voice message';
      case 'file':
        return '📎 ${repliedMessage!.fileName ?? 'File'}';
      default:
        return repliedMessage!.content;
    }
  }

  Widget _buildMessageContent() {
    switch (message.messageType) {
      case 'text':
        return Text(
          message.content,
          style: TextStyle(
            fontSize: 14,
            color: isMe ? Colors.white : Colors.black87,
          ),
        );
      case 'image':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: message.fileUrl != null && message.fileUrl!.isNotEmpty
                  ? _buildImageWidget(message.fileUrl!)
                  : Container(
                      width: 200,
                      height: 200,
                      color: Colors.grey[300],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.image_not_supported, size: 50),
                          const SizedBox(height: 8),
                          Text(
                            'No image URL',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            if (message.content.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                message.content,
                style: TextStyle(
                  fontSize: 14,
                  color: isMe ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ],
        );
      case 'file':
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isMe ? Colors.blue[700] : Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.attach_file,
                color: isMe ? Colors.white : Colors.black87,
                size: 20,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.fileName ?? 'File',
                      style: TextStyle(
                        fontSize: 14,
                        color: isMe ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (message.fileSize != null)
                      Text(
                        _formatFileSize(message.fileSize!),
                        style: TextStyle(
                          fontSize: 12,
                          color: isMe ? Colors.white70 : Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      case 'voice':
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isMe ? Colors.blue[700] : Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.mic,
                color: isMe ? Colors.white : Colors.black87,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Voice message',
                style: TextStyle(
                  fontSize: 14,
                  color: isMe ? Colors.white : Colors.black87,
                ),
              ),
              if (message.duration != null) ...[
                const SizedBox(width: 8),
                Text(
                  _formatDuration(message.duration!),
                  style: TextStyle(
                    fontSize: 12,
                    color: isMe ? Colors.white70 : Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        );
      default:
        return Text(
          message.content,
          style: TextStyle(
            fontSize: 14,
            color: isMe ? Colors.white : Colors.black87,
          ),
        );
    }
  }

  Widget _buildReactionsDisplay() {
    // Group reactions by emoji and count them
    final Map<String, int> reactionCounts = {};
    for (final reaction in message.reactions) {
      reactionCounts[reaction.reaction] = (reactionCounts[reaction.reaction] ?? 0) + 1;
    }

    return Container(
      margin: const EdgeInsets.only(top: 6),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: reactionCounts.entries.map((entry) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  entry.key,
                  style: const TextStyle(fontSize: 14),
                ),
                if (entry.value > 1) ...[
                   const SizedBox(width: 4),
                   Text(
                     entry.value.toString(),
                     style: TextStyle(
                       fontSize: 11,
                       fontWeight: FontWeight.w600,
                       color: Colors.grey[600],
                     ),
                   ),
                 ]
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  List<Widget> _buildMessageStatus() {
    return [
      const SizedBox(width: 4),
      Icon(
        message.read
            ? Icons.done_all
            : message.delivered
                ? Icons.done_all
                : Icons.done,
        size: 14,
        color: message.read
            ? Colors.blue[300]
            : Colors.white70,
      ),
    ];
  }

  void _showMessageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Reaction row
            if (onReact != null) _buildReactionRow(context),
            
            // Divider
            if (onReact != null) const Divider(height: 1),
            
            // Action buttons row
            _buildActionButtonsRow(context),
          ],
        ),
      ),
    );
  }

  Widget _buildReactionRow(BuildContext context) {
    final reactions = ['👍', '❤️', '😂', '😮', '😢', '😡'];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: reactions.map((emoji) {
          return GestureDetector(
             onTap: () {
               Navigator.pop(context);
               if (onReact != null) {
                 onReact!(emoji);
               }
             },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionButtonsRow(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (onReply != null)
            _buildActionButton(
              icon: Icons.reply,
              label: 'Reply',
              onTap: () {
                Navigator.pop(context);
                onReply!();
              },
            ),
          if (onForward != null)
            _buildActionButton(
              icon: Icons.forward,
              label: 'Forward',
              onTap: () {
                Navigator.pop(context);
                onForward!();
              },
            ),
          _buildActionButton(
            icon: Icons.copy,
            label: 'Copy',
            onTap: () {
              Navigator.pop(context);
              _copyMessage();
            },
          ),
          if (onDeleteForEveryone != null || onDelete != null)
            _buildActionButton(
              icon: Icons.delete,
              label: 'Delete',
              color: Colors.red,
              onTap: () {
                Navigator.pop(context);
                _showDeleteDialog(context);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color ?? Colors.grey[700],
              size: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color ?? Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  void _copyMessage() {
    Clipboard.setData(ClipboardData(text: message.content));
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('This message will be deleted for everyone. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
                Navigator.pop(context);
                if (onDeleteForEveryone != null) {
                  onDeleteForEveryone!();
                } else {
                  onDelete!();
                }
              },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  Widget _buildImageWidget(String imageUrl) {
    // Handle local file URLs for immediate preview
    if (imageUrl.startsWith('file://')) {
      final filePath = imageUrl.substring(7); // Remove 'file://' prefix
      return Image.file(
        File(filePath),
        width: 200,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 200,
            height: 200,
            color: Colors.grey[300],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.broken_image, size: 50),
                const SizedBox(height: 8),
                Text(
                  'Failed to load image',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      );
    }
    
    // Handle network URLs
    final networkUrl = imageUrl.startsWith('http') 
        ? imageUrl
        : 'http://localhost:4001$imageUrl';
    
    return Image.network(
      networkUrl,
      width: 200,
      height: 200,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: 200,
          height: 200,
          color: Colors.grey[100],
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        print('Error loading image: $error');
        print('Image URL: $networkUrl');
        return Container(
          width: 200,
          height: 200,
          color: Colors.grey[300],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.broken_image, size: 50),
              const SizedBox(height: 8),
              Text(
                'Failed to load image',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}