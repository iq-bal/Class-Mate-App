import 'dart:io';
import 'package:classmate/services/chat/ai_chat_services.dart';
import 'package:flutter/material.dart';

enum AiChatState { idle, loading, success, error }

class AiChatController {
  final AiChatServices _aiChatServices = AiChatServices();

  // State management
  final ValueNotifier<AiChatState> stateNotifier = ValueNotifier<AiChatState>(AiChatState.idle);

  String? errorMessage;

  Future<void> uploadPdf(File pdfFile) async {
    stateNotifier.value = AiChatState.loading;
    try {
      await _aiChatServices.uploadPdf(pdfFile);
      stateNotifier.value = AiChatState.success;
    } catch (error) {
      errorMessage = error.toString();
      stateNotifier.value = AiChatState.error;
    }
  }

  Future<String> askQuestion(String question) async {
    stateNotifier.value = AiChatState.loading;
    try {
      final response = await _aiChatServices.askQuestion(question);
      stateNotifier.value = AiChatState.success;
      return response; // Returning the answer here
    } catch (error) {
      errorMessage = error.toString();
      stateNotifier.value = AiChatState.error;
      rethrow;
    }
  }
}
