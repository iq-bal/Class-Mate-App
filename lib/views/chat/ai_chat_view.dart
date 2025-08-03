import 'package:classmate/controllers/chat/ai_chat_controller.dart';
import 'package:classmate/models/ai_assistant/knowledge_base_model.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class AIChatView extends StatefulWidget {
  const AIChatView({super.key});

  @override
  _AIChatViewState createState() => _AIChatViewState();
}

class _AIChatViewState extends State<AIChatView> {
  final TextEditingController _questionController = TextEditingController();
  final AiChatController _controller = AiChatController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.stateNotifier.addListener(_handleStateChange);
    _controller.knowledgeBasesNotifier.addListener(_handleStateChange);
    _controller.selectedKnowledgeBaseNotifier.addListener(_handleStateChange);
    
    // Load existing knowledge bases
    _loadKnowledgeBases();
  }

  @override
  void dispose() {
    _questionController.dispose();
    _scrollController.dispose();
    _controller.stateNotifier.removeListener(_handleStateChange);
    _controller.knowledgeBasesNotifier.removeListener(_handleStateChange);
    _controller.selectedKnowledgeBaseNotifier.removeListener(_handleStateChange);
    _controller.dispose();
    super.dispose();
  }

  void _handleStateChange() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadKnowledgeBases() async {
    try {
      await _controller.loadKnowledgeBases();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading knowledge bases: $e')),
        );
      }
    }
  }

  Future<void> _pickAndUploadPdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        await _controller.uploadPdf(file);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PDF uploaded successfully')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading PDF: $e')),
        );
      }
    }
  }

  Future<void> _askQuestion() async {
    final question = _questionController.text.trim();
    if (question.isEmpty) return;

    try {
      await _controller.askQuestion(question);
      _questionController.clear();
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
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

  Future<void> _deleteKnowledgeBase(KnowledgeBase knowledgeBase) async {
    try {
      await _controller.deleteKnowledgeBase(knowledgeBase.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deleted ${knowledgeBase.filename}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting knowledge base: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _controller.stateNotifier.value == AiChatState.loading;
    final knowledgeBases = _controller.knowledgeBasesNotifier.value;
    final selectedKnowledgeBase = _controller.selectedKnowledgeBaseNotifier.value;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue[900],
        title: const Text(
          'PDF Knowledge Assistant',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadKnowledgeBases,
          ),
        ],
      ),
      body: Column(
        children: [
          // Knowledge base selector
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Knowledge Bases',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: isLoading ? null : _pickAndUploadPdf,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Upload PDF'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (knowledgeBases.isEmpty && !isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'No PDFs uploaded yet. Upload a PDF to get started.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: knowledgeBases.length,
                      itemBuilder: (context, index) {
                        final kb = knowledgeBases[index];
                        final isSelected = selectedKnowledgeBase?.id == kb.id;
                        
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InkWell(
                            onTap: () => _controller.selectKnowledgeBase(kb),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.blue[700] : Colors.grey[200],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.picture_as_pdf,
                                    size: 16,
                                    color: isSelected ? Colors.white : Colors.grey[700],
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    kb.filename,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.black87,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  if (isSelected)
                                    InkWell(
                                      onTap: () => _deleteKnowledgeBase(kb),
                                      child: const Icon(
                                        Icons.close,
                                        size: 16,
                                        color: Colors.white70,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // Chat messages
          Expanded(
            child: _controller.messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.question_answer_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          selectedKnowledgeBase != null
                              ? 'Ask questions about ${selectedKnowledgeBase.filename}'
                              : 'Upload or select a PDF to start asking questions',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _controller.messages.length,
                    itemBuilder: (context, index) {
                      final message = _controller.messages[index];
                      final isUser = message['role'] == 'user';
                      
                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(12),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.8,
                          ),
                          decoration: BoxDecoration(
                            color: isUser ? Colors.blue[700] : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Text(
                            message['content']!,
                            style: TextStyle(
                              fontSize: 14,
                              color: isUser ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Loading indicator
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),

          // Input field
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _questionController,
                      decoration: InputDecoration(
                        hintText: selectedKnowledgeBase != null
                            ? 'Ask about ${selectedKnowledgeBase.filename}...'
                            : 'Select a PDF first...',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        border: InputBorder.none,
                      ),
                      enabled: selectedKnowledgeBase != null && !isLoading,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Color(0xFF346666)),
                    onPressed: (selectedKnowledgeBase != null && !isLoading)
                        ? _askQuestion
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
