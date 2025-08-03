import 'package:flutter/material.dart';
import 'package:classmate/controllers/chat/chat_controller.dart';
import 'package:classmate/models/chat/message.dart';
import 'package:classmate/views/chat/widgets/message_bubble.dart';
import 'package:classmate/views/chat/call_screen.dart';
import 'package:classmate/config/app_config.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:io';

class ChatScreenView extends StatefulWidget {
  final String withUserId;
  final String withUserName;
  final String? withUserProfilePicture;
  final String? currentUserProfilePicture;
  final ChatController chatController;

  const ChatScreenView({
    super.key,
    required this.withUserId,
    required this.withUserName,
    this.withUserProfilePicture,
    this.currentUserProfilePicture,
    required this.chatController,
  });

  @override
  _ChatScreenViewState createState() => _ChatScreenViewState();
}

class _ChatScreenViewState extends State<ChatScreenView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  FlutterSoundRecorder? _audioRecorder;
  bool _isTyping = false;
  bool _isRecording = false;
  Timer? _recordingTimer;
  int _recordingDuration = 0;
  Message? _replyingToMessage;
  bool _showReplyPreview = false;
  Message? _editingMessage;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
    // Set current conversation in controller
    widget.chatController.setCurrentConversation(widget.withUserId);
    _markMessagesAsRead();
    
    // Listen for typing changes
    _messageController.addListener(_onTypingChanged);
    
    // Listen for new messages to auto-scroll
    widget.chatController.messagesNotifier.addListener(_onMessagesChanged);
    
    // // Listen for message ID updates
    widget.chatController.onMessageIdUpdated = _onMessageIdUpdated;
  }

  Future<void> _initializeRecorder() async {
    try {
      _audioRecorder = FlutterSoundRecorder();
      await _audioRecorder!.openRecorder();
    } catch (e) {
      print('Error initializing recorder: $e');
    }
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTypingChanged);
    widget.chatController.messagesNotifier.removeListener(_onMessagesChanged);
    widget.chatController.onMessageIdUpdated = null; // Clear the callback
    _messageController.dispose();
    _scrollController.dispose();
    _recordingTimer?.cancel();
    if (_audioRecorder != null) {
      if (_audioRecorder!.isRecording) {
        _audioRecorder!.stopRecorder();
      }
      _audioRecorder!.closeRecorder();
    }
    if (_isTyping) {
      widget.chatController.stopTyping(widget.withUserId);
    }
    // Clear current conversation when leaving chat screen
    widget.chatController.clearCurrentConversation();
    super.dispose();
  }



  void _markMessagesAsRead() {
    widget.chatController.markMessagesAsRead(widget.withUserId);
  }

  void _onTypingChanged() {
    final isCurrentlyTyping = _messageController.text.isNotEmpty;
    if (isCurrentlyTyping != _isTyping) {
      if (mounted) {
        setState(() {
          _isTyping = isCurrentlyTyping;
        });
      }
      
      if (_isTyping) {
        widget.chatController.startTyping(widget.withUserId);
      } else {
        widget.chatController.stopTyping(widget.withUserId);
      }
    }
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isNotEmpty) {
      if (_isEditing) {
        // Save edit
        _saveEdit();
      } else {
        // Handle reply to message (including temporary messages)
        String? validReplyToId;
        if (_replyingToMessage != null) {
          if (_replyingToMessage!.id.startsWith('temp_')) {
            // For temporary messages, try to find the corresponding real message
            final currentMessages = widget.chatController.messagesNotifier.value;
            final realMessage = currentMessages.firstWhere(
              (m) => !m.id.startsWith('temp_') &&
                     m.content == _replyingToMessage!.content &&
                     m.senderId == _replyingToMessage!.senderId &&
                     m.receiverId == _replyingToMessage!.receiverId,
              orElse: () => _replyingToMessage!,
            );
            
            // If we found a real message, use its ID; otherwise send without replyToId
            if (!realMessage.id.startsWith('temp_')) {
              validReplyToId = realMessage.id;
              // Update the reference for future use
              setState(() {
                _replyingToMessage = realMessage;
              });
            }
            // If still temporary, send without replyToId (no blocking)
          } else {
            validReplyToId = _replyingToMessage!.id;
          }
        }
        
        // Send new message
        widget.chatController.sendMessage(
          receiverId: widget.withUserId,
          content: content,
          type: 'text',
          replyToId: validReplyToId,
        );
        _messageController.clear();
        _clearReply();
        _scrollToBottom();
      }
    }
  }

  void _setReplyMessage(Message message) {
    setState(() {
      _replyingToMessage = message;
      _showReplyPreview = true;
    });
    // Focus on text field
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void _clearReply() {
    setState(() {
      _replyingToMessage = null;
      _showReplyPreview = false;
    });
  }

  void _sendImageMessage() async {
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // Handle reply to message (including temporary messages)
      String? validReplyToId;
      if (_replyingToMessage != null) {
        if (_replyingToMessage!.id.startsWith('temp_')) {
          // For temporary messages, try to find the corresponding real message
          final currentMessages = widget.chatController.messagesNotifier.value;
          final realMessage = currentMessages.firstWhere(
            (m) => !m.id.startsWith('temp_') &&
                   m.content == _replyingToMessage!.content &&
                   m.senderId == _replyingToMessage!.senderId &&
                   m.receiverId == _replyingToMessage!.receiverId,
            orElse: () => _replyingToMessage!,
          );
          
          // If we found a real message, use its ID; otherwise send without replyToId
          if (!realMessage.id.startsWith('temp_')) {
            validReplyToId = realMessage.id;
            // Update the reference for future use
            setState(() {
              _replyingToMessage = realMessage;
            });
          }
          // If still temporary, send without replyToId (no blocking)
        } else {
          validReplyToId = _replyingToMessage!.id;
        }
      }
      
      final file = File(image.path);
      // Send actual image file
      widget.chatController.sendMessage(
        receiverId: widget.withUserId,
        content: '', // Optional caption
        type: 'image',
        file: file,
        replyToId: validReplyToId,
      );
      _clearReply();
      _scrollToBottom();
    }
  }

  void _sendFileMessage() async {
    // Use file_picker to pick any type of file
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.single.path != null) {
        // Handle reply to message (including temporary messages)
        String? validReplyToId;
        if (_replyingToMessage != null) {
          if (_replyingToMessage!.id.startsWith('temp_')) {
            // For temporary messages, try to find the corresponding real message
            final currentMessages = widget.chatController.messagesNotifier.value;
            final realMessage = currentMessages.firstWhere(
              (m) => !m.id.startsWith('temp_') &&
                     m.content == _replyingToMessage!.content &&
                     m.senderId == _replyingToMessage!.senderId &&
                     m.receiverId == _replyingToMessage!.receiverId,
              orElse: () => _replyingToMessage!,
            );
            
            // If we found a real message, use its ID; otherwise send without replyToId
            if (!realMessage.id.startsWith('temp_')) {
              validReplyToId = realMessage.id;
              // Update the reference for future use
              setState(() {
                _replyingToMessage = realMessage;
              });
            }
            // If still temporary, send without replyToId (no blocking)
          } else {
            validReplyToId = _replyingToMessage!.id;
          }
        }
        
        final file = File(result.files.single.path!);
        // Send actual file
        widget.chatController.sendMessage(
          receiverId: widget.withUserId,
          content: '', // Optional description
          type: 'file',
          file: file,
          replyToId: validReplyToId,
        );
        _clearReply();
        _scrollToBottom();
      }
    } catch (e) {
      print('Error picking file: $e');
      // Show error message to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick file: $e')),
      );
    }
  }

  Future<void> _startVoiceRecording() async {
    try {
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission required')),
        );
        return;
      }
      
      if (_audioRecorder == null) {
        await _initializeRecorder();
      }
      
      if (!_audioRecorder!.isRecording) {
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/voice_${DateTime.now().millisecondsSinceEpoch}.aac';
        
        await _audioRecorder!.startRecorder(
          toFile: filePath,
          codec: Codec.aacADTS,
        );
        
        setState(() {
          _isRecording = true;
          _recordingDuration = 0;
        });
        
        // Start timer to track recording duration
        _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _recordingDuration++;
          });
        });
      }
    } catch (e) {
      print('Error starting recording: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start recording: $e')),
      );
    }
  }

  Future<void> _stopVoiceRecording() async {
    try {
      if (_audioRecorder != null && _audioRecorder!.isRecording) {
        final path = await _audioRecorder!.stopRecorder();
        _recordingTimer?.cancel();
        
        setState(() {
          _isRecording = false;
          _recordingDuration = 0;
        });
        
        if (path != null && path.isNotEmpty) {
          final file = File(path);
          if (await file.exists()) {
            // Handle reply to message (including temporary messages)
            String? validReplyToId;
            if (_replyingToMessage != null) {
              if (_replyingToMessage!.id.startsWith('temp_')) {
                // For temporary messages, try to find the corresponding real message
                final currentMessages = widget.chatController.messagesNotifier.value;
                final realMessage = currentMessages.firstWhere(
                  (m) => !m.id.startsWith('temp_') &&
                         m.content == _replyingToMessage!.content &&
                         m.senderId == _replyingToMessage!.senderId &&
                         m.receiverId == _replyingToMessage!.receiverId,
                  orElse: () => _replyingToMessage!,
                );
                
                // If we found a real message, use its ID; otherwise send without replyToId
                if (!realMessage.id.startsWith('temp_')) {
                  validReplyToId = realMessage.id;
                  // Update the reference for future use
                  setState(() {
                    _replyingToMessage = realMessage;
                  });
                }
                // If still temporary, send without replyToId (no blocking)
              } else {
                validReplyToId = _replyingToMessage!.id;
              }
            }
            
            // Send voice message
            widget.chatController.sendMessage(
              receiverId: widget.withUserId,
              content: 'Voice message',
              type: 'voice',
              file: file,
              replyToId: validReplyToId,
            );
            _clearReply();
            _scrollToBottom();
          }
        }
      }
    } catch (e) {
      print('Error stopping recording: $e');
      _recordingTimer?.cancel();
      setState(() {
        _isRecording = false;
        _recordingDuration = 0;
      });
    }
  }

  void _cancelVoiceRecording() async {
    try {
      if (_audioRecorder != null && _audioRecorder!.isRecording) {
        await _audioRecorder!.stopRecorder();
      }
      _recordingTimer?.cancel();
      
      setState(() {
        _isRecording = false;
        _recordingDuration = 0;
      });
    } catch (e) {
      print('Error canceling recording: $e');
      _recordingTimer?.cancel();
      setState(() {
        _isRecording = false;
        _recordingDuration = 0;
      });
    }
  }

  void _onMessagesChanged() {
    _scrollToBottom();
    
    // Update _replyingToMessage if it was pointing to a temporary message that got replaced
    if (_replyingToMessage != null && _replyingToMessage!.id.startsWith('temp_')) {
      final currentMessages = widget.chatController.messagesNotifier.value;
      // Look for a message with the same content, sender, and receiver but with a real ID
      final replacementMessage = currentMessages.firstWhere(
        (m) => !m.id.startsWith('temp_') &&
               m.content == _replyingToMessage!.content &&
               m.senderId == _replyingToMessage!.senderId &&
               m.receiverId == _replyingToMessage!.receiverId,
        orElse: () => _replyingToMessage!, // Return original if no replacement found
      );
      
      // If we found a replacement message, update the reference
      if (replacementMessage.id != _replyingToMessage!.id) {
        setState(() {
          _replyingToMessage = replacementMessage;
        });
        print('🔄 Updated _replyingToMessage from temp ID ${_replyingToMessage!.id} to real ID ${replacementMessage.id}');
      }
    }
  }

  void _onMessageIdUpdated(String oldId, String newId) {
    // Update _replyingToMessage if it was pointing to the temporary message
    if (_replyingToMessage != null && _replyingToMessage!.id == oldId) {
      // Find the updated message with the new ID
      final currentMessages = widget.chatController.messagesNotifier.value;
      final updatedMessage = currentMessages.firstWhere(
        (m) => m.id == newId,
        orElse: () => _replyingToMessage!, // Fallback to original if not found
      );
      
      if (updatedMessage.id == newId) {
        setState(() {
          _replyingToMessage = updatedMessage;
        });
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: widget.withUserProfilePicture != null
                      ? NetworkImage('${AppConfig.imageServer}${widget.withUserProfilePicture}')
                      : const AssetImage('assets/images/avatar.png') as ImageProvider,
                  backgroundColor: Colors.grey[300],
                ),
                // Online status indicator
                ValueListenableBuilder<Map<String, bool>>(
                  valueListenable: widget.chatController.onlineStatusNotifier,
                  builder: (context, onlineStatus, _) {
                    final isOnline = onlineStatus[widget.withUserId] ?? false;
                    if (!isOnline) return const SizedBox.shrink();
                    
                    return Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        width: 12,
                        height: 12,
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.withUserName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Typing indicator or online status
                  ValueListenableBuilder<Map<String, bool>>(
                    valueListenable: widget.chatController.typingStatusNotifier,
                    builder: (context, typingStatus, _) {
                      final isTyping = typingStatus[widget.withUserId] ?? false;
                      if (isTyping) {
                        return Text(
                          'typing...',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[600],
                            fontStyle: FontStyle.italic,
                          ),
                        );
                      }
                      
                      return ValueListenableBuilder<Map<String, bool>>(
                        valueListenable: widget.chatController.onlineStatusNotifier,
                        builder: (context, onlineStatus, _) {
                          final isOnline = onlineStatus[widget.withUserId] ?? false;
                          return Text(
                            isOnline ? 'online' : 'offline',
                            style: TextStyle(
                              fontSize: 12,
                              color: isOnline ? Colors.green : Colors.grey[600],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam, color: Colors.black87),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CallScreen(
                    chatController: widget.chatController,
                    participantId: widget.withUserId,
                    participantName: widget.withUserName,
                    participantProfilePicture: widget.withUserProfilePicture,
                    callType: 'video',
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.call, color: Colors.black87),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CallScreen(
                    chatController: widget.chatController,
                    participantId: widget.withUserId,
                    participantName: widget.withUserName,
                    participantProfilePicture: widget.withUserProfilePicture,
                    callType: 'voice',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: ValueListenableBuilder<List<Message>>(
              valueListenable: widget.chatController.messagesNotifier,
              builder: (context, messages, _) {
                
                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'No messages yet. Start a conversation!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  );
                }
                
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = widget.chatController.isMessageFromCurrentUser(message);
                    
                    return Dismissible(
                      key: ValueKey(message.id),
                      direction: isMe 
                          ? DismissDirection.endToStart // Swipe left for sent messages
                          : DismissDirection.startToEnd, // Swipe right for received messages
                      confirmDismiss: (direction) async {
                        // Set reply message and don't actually dismiss
                        _setReplyMessage(message);
                        return false; // Don't dismiss the item
                      },
                      background: Container(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        color: Colors.blue.withOpacity(0.1),
                        child: Row(
                          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                          children: [
                            if (!isMe) ...[  
                              Icon(Icons.reply, color: Colors.blue, size: 24),
                              SizedBox(width: 8),
                              Text('Reply', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                            ],
                            if (isMe) ...[  
                              Text('Reply', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                              SizedBox(width: 8),
                              Icon(Icons.reply, color: Colors.blue, size: 24),
                            ],
                          ],
                        ),
                      ),
                      child: MessageBubble(
                          message: message,
                          isMe: isMe,
                          currentUserProfilePicture: widget.currentUserProfilePicture,
                          otherUserProfilePicture: widget.withUserProfilePicture,
                          repliedMessage: message.replyToMessage ?? 
                              (message.replyTo != null 
                                  ? messages.firstWhere(
                                      (m) => m.id == message.replyTo,
                                      orElse: () => Message(
                                        id: '',
                                        senderId: '',
                                        receiverId: '',
                                        content: 'Message not found',
                                        messageType: 'text',
                                        reactions: [],
                                        forwarded: false,
                                        read: false,
                                        delivered: false,
                                        edited: false,
                                        createdAt: DateTime.now(),
                                      ),
                                    )
                                  : null),
                          repliedToUserName: (() {
                            String? userName;
                            if (message.replyToMessage != null) {
                              final isRepliedToMe = widget.chatController.isMessageFromCurrentUser(message.replyToMessage!);
                              userName = isRepliedToMe ? 'You' : widget.withUserName;
                            } else if (message.replyTo != null) {
                              final repliedMsg = messages.firstWhere(
                                (m) => m.id == message.replyTo,
                                orElse: () => Message(
                                  id: '',
                                  senderId: '',
                                  receiverId: '',
                                  content: '',
                                  messageType: 'text',
                                  reactions: [],
                                  forwarded: false,
                                  read: false,
                                  delivered: false,
                                  edited: false,
                                  createdAt: DateTime.now(),
                                ),
                              );
                              if (repliedMsg.id.isEmpty) {
                                userName = 'Unknown';
                              } else {
                                final isRepliedToMe = widget.chatController.isMessageFromCurrentUser(repliedMsg);
                                userName = isRepliedToMe ? 'You' : widget.withUserName;
                              }
                            } else {
                              userName = null;
                            }
                            return userName;
                          })(),
                          onReact: (emoji) {
                            widget.chatController.reactToMessage(
                              message.id,
                              emoji,
                            );
                          },
                          onReply: () {
                            _setReplyMessage(message);
                          },
                          onForward: () {
                            _showForwardDialog(message);
                          },
                          onEdit: message.senderId == widget.chatController.currentUserId && !message.id.startsWith('temp_')
                              ? () {
                                  // Implement edit functionality
                                  _showEditDialog(message);
                                }
                              : null,
                          onDeleteForEveryone: () {
                            widget.chatController.deleteMessage(message.id);
                          },
                        ),
                    );
                  },
                );
              },
            ),
          ),
          
          // Message input
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Reply preview
                if (_showReplyPreview && _replyingToMessage != null)
                  _buildReplyPreview(),
                // Edit preview
                if (_isEditing && _editingMessage != null)
                  _buildEditPreview(),
                // Message input
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _isRecording ? _buildRecordingUI() : _buildNormalInputUI(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNormalInputUI() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.attach_file, color: Colors.grey),
          onPressed: _sendFileMessage,
        ),
        IconButton(
          icon: const Icon(Icons.image, color: Colors.grey),
          onPressed: _sendImageMessage,
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(24),
            ),
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Send messages',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Voice recording button
        GestureDetector(
          onLongPressStart: (_) => _startVoiceRecording(),
          onLongPressEnd: (_) => _stopVoiceRecording(),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[600],
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.mic, color: Colors.white),
              onPressed: () {
                // Show instruction for long press
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Hold to record voice message'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            color: _isEditing ? Colors.orange : Colors.blue,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              _isEditing ? Icons.check : Icons.send,
              color: Colors.white,
            ),
            onPressed: _sendMessage,
          ),
        ),
      ],
    );
  }

  Widget _buildReplyPreview() {
    if (_replyingToMessage == null) return const SizedBox.shrink();
    
    final isReplyingToMe = widget.chatController.isMessageFromCurrentUser(_replyingToMessage!);
    
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(left: 16, right: 16, top: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: Colors.blue,
            width: 3,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Replying to ${isReplyingToMe ? 'yourself' : widget.withUserName}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _replyingToMessage!.messageType == 'text' 
                      ? _replyingToMessage!.content
                      : _replyingToMessage!.messageType == 'image'
                          ? '📷 Image'
                          : _replyingToMessage!.messageType == 'voice'
                              ? '🎤 Voice message'
                              : '📎 File',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.grey[600], size: 20),
            onPressed: _clearReply,
            constraints: BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildEditPreview() {
    if (_editingMessage == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(left: 16, right: 16, top: 8),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: Colors.orange,
            width: 3,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Editing message',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _editingMessage!.content,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.grey[600], size: 20),
            onPressed: _cancelEdit,
            constraints: BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingUI() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.mic, color: Colors.red[600]),
                const SizedBox(width: 8),
                Text(
                  'Recording... ${_formatDuration(_recordingDuration)}',
                  style: TextStyle(
                    color: Colors.red[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                // Animated recording indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Cancel recording
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[600],
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: _cancelVoiceRecording,
          ),
        ),
        const SizedBox(width: 8),
        // Stop and send recording
        Container(
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.stop, color: Colors.white),
            onPressed: _stopVoiceRecording,
          ),
        ),
      ],
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _showEditDialog(Message message) {
    setState(() {
      _editingMessage = message;
      _isEditing = true;
      _messageController.text = message.content;
      _clearReply(); // Clear any existing reply when editing
    });
    
    // Focus the text field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }
  
  void _cancelEdit() {
    setState(() {
      _editingMessage = null;
      _isEditing = false;
      _messageController.clear();
    });
  }
  
  void _saveEdit() async {
    if (_editingMessage == null) return;
    
    final newContent = _messageController.text.trim();
    if (newContent.isNotEmpty && newContent != _editingMessage!.content) {
      // Check if this is a temporary message
      if (_editingMessage!.id.startsWith('temp_')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot edit message while it\'s being sent. Please wait and try again.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      
      await widget.chatController.editMessage(
        _editingMessage!.id,
        newContent,
      );
      
      // Check if there was an error
       if (widget.chatController.errorMessage != null && widget.chatController.errorMessage!.isNotEmpty) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text(widget.chatController.errorMessage!),
             backgroundColor: Colors.red,
           ),
         );
         // Clear the error message
         widget.chatController.errorMessage = null;
         return;
       }
    }
    
    setState(() {
      _editingMessage = null;
      _isEditing = false;
      _messageController.clear();
    });
  }

  void _showForwardDialog(Message message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Forward Message'),
        content: const Text('Forward functionality will be implemented with user selection.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // For now, just close the dialog
              // In a full implementation, you would:
              // 1. Show a list of users/conversations
              // 2. Allow selection
              // 3. Call widget.chatController.forwardMessage(message.id, selectedUserIds)
              Navigator.pop(context);
            },
            child: const Text('Forward'),
          ),
        ],
      ),
    );
  }
}
