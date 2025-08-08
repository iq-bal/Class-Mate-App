import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatbotWidget extends StatefulWidget {
  final File? selectedPdf;
  final VoidCallback onPickPdf;
  final Function(File, int, String, String) onGenerateQuestions;
  final bool isServiceHealthy;

  const ChatbotWidget({
    super.key,
    this.selectedPdf,
    required this.onPickPdf,
    required this.onGenerateQuestions,
    required this.isServiceHealthy,
  });

  @override
  State<ChatbotWidget> createState() => _ChatbotWidgetState();
}

class _ChatbotWidgetState extends State<ChatbotWidget> {
  final TextEditingController _testTitleController = TextEditingController();
  int _numQuestions = 5;
  String _difficulty = 'medium';

  @override
  void dispose() {
    _testTitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chatbot Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.smart_toy,
                  color: Colors.blue.shade600,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Question Generator',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Upload a PDF to generate quiz questions',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Chat Messages
          _buildChatMessages(),
          
          const SizedBox(height: 20),
          
          // PDF Upload Section
          _buildPdfUploadSection(),
          
          if (widget.selectedPdf != null) ...[
            const SizedBox(height: 20),
            _buildQuestionSettings(),
            const SizedBox(height: 20),
            _buildGenerateButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildChatMessages() {
    return Column(
      children: [
        _buildBotMessage("Hi! I'm your AI assistant. I can help you generate quiz questions from PDF documents. 📚"),
        const SizedBox(height: 12),
        _buildBotMessage("Simply upload a PDF file and I'll create multiple-choice questions based on the content. Let's get started! 🚀"),
        if (!widget.isServiceHealthy) ...[
          const SizedBox(height: 12),
          _buildBotMessage(
            "⚠️ The question generator service is currently offline. Please ensure the service is running on localhost:8001 to generate questions.",
            isError: true,
          ),
        ],
      ],
    );
  }

  Widget _buildBotMessage(String message, {bool isError = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isError ? Colors.red.shade100 : Colors.blue.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isError ? Icons.warning : Icons.smart_toy,
            color: isError ? Colors.red.shade600 : Colors.blue.shade600,
            size: 16,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isError ? Colors.red.shade50 : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: isError ? Colors.red.shade700 : Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPdfUploadSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: widget.selectedPdf != null ? Colors.green.shade300 : Colors.grey.shade300,
          style: BorderStyle.solid,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
        color: widget.selectedPdf != null ? Colors.green.shade50 : Colors.grey.shade50,
      ),
      child: Column(
        children: [
          Icon(
            widget.selectedPdf != null ? Icons.check_circle : Icons.upload_file,
            size: 48,
            color: widget.selectedPdf != null ? Colors.green.shade600 : Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          if (widget.selectedPdf != null) ...[
            Text(
              'PDF Selected',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.selectedPdf!.path.split('/').last,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.green.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ] else ...[
            Text(
              'Upload PDF Document',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Drag and drop or click to select a PDF file',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: widget.onPickPdf,
            icon: Icon(
              widget.selectedPdf != null ? Icons.refresh : Icons.upload,
              size: 18,
            ),
            label: Text(
              widget.selectedPdf != null ? 'Change PDF' : 'Select PDF',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionSettings() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question Settings',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          const SizedBox(height: 16),
          
          // Test Title
          TextFormField(
            controller: _testTitleController,
            decoration: InputDecoration(
              labelText: 'Quiz Title',
              hintText: 'Enter quiz title',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Number of Questions
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Number of Questions',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      value: _numQuestions,
                      items: List.generate(20, (index) => index + 1)
                          .map((num) => DropdownMenuItem(
                                value: num,
                                child: Text('$num'),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _numQuestions = value!;
                        });
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Difficulty Level',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _difficulty,
                      items: const [
                        DropdownMenuItem(value: 'easy', child: Text('Easy')),
                        DropdownMenuItem(value: 'medium', child: Text('Medium')),
                        DropdownMenuItem(value: 'hard', child: Text('Hard')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _difficulty = value!;
                        });
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton() {
    final isEnabled = widget.selectedPdf != null && widget.isServiceHealthy;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isEnabled ? _handleGenerateQuestions : null,
        icon: const Icon(Icons.auto_awesome, size: 20),
        label: Text(
          'Generate Questions',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade600,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          disabledForegroundColor: Colors.grey.shade500,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _handleGenerateQuestions() {
    if (widget.selectedPdf == null) return;
    
    final testTitle = _testTitleController.text.trim().isEmpty 
        ? 'Generated Quiz' 
        : _testTitleController.text.trim();
    
    widget.onGenerateQuestions(
      widget.selectedPdf!,
      _numQuestions,
      _difficulty,
      testTitle,
    );
  }
}
