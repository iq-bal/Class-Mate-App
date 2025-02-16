import 'dart:async';
import 'dart:io';
import 'package:classmate/models/chat/message.dart';
import 'package:classmate/services/chat/chat_service.dart';
import 'package:classmate/views/chat/supporting_widgets/chat_input.dart';
import 'package:classmate/views/chat/supporting_widgets/message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;

  const ChatScreen({
    required this.receiverId,
    required this.receiverName,
    super.key,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Message> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  Timer? _typingTimer;
  late ChatService _chatService;

  @override
  void initState() {
    super.initState();
    _chatService = context.read<ChatService>();
    _setupSocketListeners();
    _loadMessages();
  }

  void _setupSocketListeners() {
    _chatService.socket
      ..on('message', _handleNewMessage)
      ..on('messageReacted', _handleMessageReaction)
      ..on('messageDeleted', _handleMessageDeletion)
      ..on('messageEdited', _handleMessageEdit)
      ..on('userTyping', _handleTypingIndicator)
      ..on('userStoppedTyping', _handleStopTyping);
  }

  void _handleNewMessage(dynamic data) {
    setState(() {
      _messages.add(Message.fromJson(data));
      _scrollToBottom();
    });
  }

  void _handleMessageReaction(dynamic data) {
    setState(() {
      final index = _messages.indexWhere((m) => m.id == data['messageId']);
      if (index != -1) {
        final message = _messages[index];
        message.reactions
          ..removeWhere((r) => r.userId == data['userId'])
          ..add(MessageReaction.fromJson(data));
        _messages[index] = message.copyWith(reactions: message.reactions);
      }
    });
  }

  void _handleMessageDeletion(dynamic data) {
    setState(() {
      if (data['forEveryone']) {
        _messages.removeWhere((m) => m.id == data['messageId']);
      } else {
        final index = _messages.indexWhere((m) => m.id == data['messageId']);
        if (index != -1) {
          final message = _messages[index];
          final deletedFor = [...message.deletedFor, _chatService.userId];
          _messages[index] = message.copyWith(deletedFor: deletedFor);
        }
      }
    });
  }

  void _handleMessageEdit(dynamic data) {
    setState(() {
      final index = _messages.indexWhere((m) => m.id == data['messageId']);
      if (index != -1) {
        _messages[index] = _messages[index].copyWith(
          content: data['newContent'],
          edited: true,
          editedAt: DateTime.now(),
        );
      }
    });
  }

  void _handleTypingIndicator(dynamic data) {
    if (data['userId'] == widget.receiverId) {
      setState(() => _isTyping = true);
    }
  }

  void _handleStopTyping(dynamic data) {
    if (data['userId'] == widget.receiverId) {
      setState(() => _isTyping = false);
    }
  }

  void _loadMessages() => _chatService.getConversations(widget.receiverId);

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    _chatService.sendMessage(
      receiverId: widget.receiverId,
      content: _messageController.text,
    );
    _messageController.clear();
    _typingTimer?.cancel();
  }

  void _handleTyping() {
    _chatService.sendTypingIndicator(widget.receiverId);
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      _chatService.sendStopTypingIndicator(widget.receiverId);
    });
  }

  void _showMessageOptions(Message message) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (message.senderId == _chatService.userId) ...[
            _buildOptionTile(Icons.edit, 'Edit', () => _showEditDialog(message)),
            _buildOptionTile(Icons.delete, 'Delete', () => _showDeleteDialog(message)),
          ],
          _buildOptionTile(Icons.reply, 'Reply', () {}),
          _buildOptionTile(Icons.emoji_emotions, 'React', () => _showReactionPicker(message)),
        ],
      ),
    );
  }

  ListTile _buildOptionTile(IconData icon, String text, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  void _showEditDialog(Message message) {
    final controller = TextEditingController(text: message.content);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Message'),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _chatService.editMessage(message.id, controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Message message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('Choose deletion scope:'),
        actions: [
          TextButton(
            onPressed: () {
              _chatService.deleteMessage(message.id, forEveryone: false);
              Navigator.pop(context);
            },
            child: const Text('For Me'),
          ),
          TextButton(
            onPressed: () {
              _chatService.deleteMessage(message.id, forEveryone: true);
              Navigator.pop(context);
            },
            child: const Text('For Everyone'),
          ),
        ],
      ),
    );
  }

  void _showReactionPicker(Message message) {
    // Implement emoji picker integration
  }

  Future<void> _showAttachmentOptions() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAttachmentTile(Icons.image, 'Image', _pickImage),
          _buildAttachmentTile(Icons.file_present, 'File', _pickFile),
        ],
      ),
    );
  }

  ListTile _buildAttachmentTile(IconData icon, String text, Function() onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      _chatService.sendMessage(
        receiverId: widget.receiverId,
        type: MessageType.image,
        file: File(image.path), content: '',
      );
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      _chatService.sendMessage(
        receiverId: widget.receiverId,
        type: MessageType.file,
        file: File(result.files.single.path!), content: '',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.receiverName),
            if (_isTyping)
              const Text('typing...', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              padding: const EdgeInsets.all(8),
              itemBuilder: (context, index) {
                final message = _messages[index];
                if (message.deletedFor.contains(_chatService.userId)) {
                  return const SizedBox.shrink();
                }
                return MessageBubble(
                  message: message,
                  isMe: message.senderId == _chatService.userId,
                  onLongPress: () => _showMessageOptions(message),
                );
              },
            ),
          ),
          ChatInput(
            controller: _messageController,
            onChanged: (_) => _handleTyping(),
            onSend: _sendMessage,
            onAttachmentPressed: _showAttachmentOptions,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }
}

class MessageType {
  static var file;
  static var image;
}