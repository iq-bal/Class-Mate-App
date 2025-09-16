import 'package:classmate/controllers/chat/ai_chat_controller.dart';
import 'package:classmate/models/ai_assistant/knowledge_base_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class PdfAIChatView extends StatefulWidget {
  final String pdfUrl;
  final String pdfFileName;

  const PdfAIChatView({
    super.key,
    required this.pdfUrl,
    required this.pdfFileName,
  });

  @override
  _PdfAIChatViewState createState() => _PdfAIChatViewState();
}

class _PdfAIChatViewState extends State<PdfAIChatView> {
  final TextEditingController _questionController = TextEditingController();
  final AiChatController _controller = AiChatController();
  final ScrollController _scrollController = ScrollController();
  bool _isDownloading = false;
  bool _isPdfReady = false;

  @override
  void initState() {
    super.initState();
    _controller.stateNotifier.addListener(_handleStateChange);
    _controller.knowledgeBasesNotifier.addListener(_handleStateChange);
    _controller.selectedKnowledgeBaseNotifier.addListener(_handleStateChange);
    
    // Automatically download and upload the PDF
    _downloadAndUploadPdf();
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

  Future<void> _downloadAndUploadPdf() async {
    setState(() {
      _isDownloading = true;
    });

    try {
      // Download PDF from URL
      final response = await http.get(Uri.parse(widget.pdfUrl));
      if (response.statusCode == 200) {
        // Save to temporary file
        final directory = await getTemporaryDirectory();
        final fileName = widget.pdfFileName.endsWith('.pdf') 
            ? widget.pdfFileName 
            : '${widget.pdfFileName}.pdf';
        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        // Upload to AI service
        await _controller.uploadPdf(file);

        // Load knowledge bases and select the uploaded one
        await _controller.loadKnowledgeBases();
        
        // Find and select the uploaded PDF
        final knowledgeBases = _controller.knowledgeBasesNotifier.value;
        final uploadedKb = knowledgeBases.firstWhere(
          (kb) => kb.filename == fileName,
          orElse: () => knowledgeBases.isNotEmpty ? knowledgeBases.last : KnowledgeBase(
            id: '', 
            filename: '', 
            uploadTime: DateTime.now(), 
            textLength: 0, 
            status: '',
          ),
        );
        
        if (uploadedKb.id.isNotEmpty) {
          _controller.selectKnowledgeBase(uploadedKb);
          setState(() {
            _isPdfReady = true;
          });
        }

        if (mounted) {
          _showModernSuccessMessage('PDF is ready for chat!');
        }
      } else {
        throw Exception('Failed to download PDF');
      }
    } catch (e) {
      if (mounted) {
        _showModernErrorDialog(
          title: 'Upload Failed',
          message: 'Unable to prepare the PDF for chat. Please try again.',
        );
      }
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  void _showModernSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showModernErrorDialog({
    required String title,
    required String message,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: Colors.red.shade500,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade500,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Okay',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
        _showModernErrorDialog(
          title: 'Question Failed',
          message: 'Unable to process your question. Please try again.',
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

  @override
  Widget build(BuildContext context) {
    final isLoading = _controller.stateNotifier.value == AiChatState.loading;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.red[600],
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PDF Chat Assistant',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              widget.pdfFileName,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Status indicator
          if (_isDownloading)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                border: Border(
                  bottom: BorderSide(color: Colors.orange.shade200),
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.orange.shade600),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Preparing PDF for chat...',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          else if (_isPdfReady)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                border: Border(
                  bottom: BorderSide(color: Colors.green.shade200),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'PDF is ready! Ask questions about the content.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.green.shade800,
                      fontWeight: FontWeight.w500,
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
                          Icons.picture_as_pdf_rounded,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isPdfReady
                              ? 'Ask questions about ${widget.pdfFileName}'
                              : _isDownloading
                                  ? 'Please wait while we prepare your PDF...'
                                  : 'PDF chat will be ready shortly',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
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
                            color: isUser ? Colors.red[600] : Colors.white,
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
                            style: GoogleFonts.inter(
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red.shade600),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'AI is thinking...',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
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
                        hintText: _isPdfReady
                            ? 'Ask about ${widget.pdfFileName}...'
                            : 'Please wait for PDF to be ready...',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        border: InputBorder.none,
                      ),
                      enabled: _isPdfReady && !isLoading,
                      maxLines: null,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.send,
                      color: _isPdfReady && !isLoading 
                          ? Colors.red.shade600 
                          : Colors.grey.shade400,
                    ),
                    onPressed: (_isPdfReady && !isLoading) ? _askQuestion : null,
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
