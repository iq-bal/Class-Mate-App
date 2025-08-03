import 'dart:io';
import 'package:classmate/services/chat/ai_chat_services.dart';
import 'package:classmate/models/ai_assistant/knowledge_base_model.dart';
import 'package:flutter/material.dart';

enum AiChatState { idle, loading, success, error }

class AiChatController {
  final AiChatServices _aiChatServices = AiChatServices();

  // State management
  final ValueNotifier<AiChatState> stateNotifier = ValueNotifier<AiChatState>(AiChatState.idle);
  final ValueNotifier<List<KnowledgeBase>> knowledgeBasesNotifier = ValueNotifier<List<KnowledgeBase>>([]);
  final ValueNotifier<KnowledgeBase?> selectedKnowledgeBaseNotifier = ValueNotifier<KnowledgeBase?>(null);

  String? errorMessage;
  List<Map<String, String>> messages = [];

  /// Upload a PDF and create a knowledge base
  Future<KnowledgeBase> uploadPdf(File pdfFile) async {
    stateNotifier.value = AiChatState.loading;
    try {
      final knowledgeBase = await _aiChatServices.uploadPdf(pdfFile);
      
      // Add to knowledge bases list
      final currentList = List<KnowledgeBase>.from(knowledgeBasesNotifier.value);
      currentList.add(knowledgeBase);
      knowledgeBasesNotifier.value = currentList;
      
      // Set as selected knowledge base
      selectedKnowledgeBaseNotifier.value = knowledgeBase;
      
      stateNotifier.value = AiChatState.success;
      return knowledgeBase;
    } catch (error) {
      errorMessage = error.toString();
      stateNotifier.value = AiChatState.error;
      rethrow;
    }
  }

  /// Ask a question about the selected knowledge base
  Future<QuestionResponse> askQuestion(String question) async {
    final selectedKB = selectedKnowledgeBaseNotifier.value;
    if (selectedKB == null) {
      throw Exception('No knowledge base selected. Please upload a PDF first.');
    }

    stateNotifier.value = AiChatState.loading;
    try {
      final response = await _aiChatServices.askQuestion(question, selectedKB.id);
      
      // Add messages to chat history
      messages.add({'role': 'user', 'content': question});
      messages.add({'role': 'assistant', 'content': response.answer});
      
      stateNotifier.value = AiChatState.success;
      return response;
    } catch (error) {
      errorMessage = error.toString();
      stateNotifier.value = AiChatState.error;
      rethrow;
    }
  }

  /// Load all knowledge bases
  Future<void> loadKnowledgeBases() async {
    stateNotifier.value = AiChatState.loading;
    try {
      final knowledgeBases = await _aiChatServices.getKnowledgeBases();
      knowledgeBasesNotifier.value = knowledgeBases;
      
      // If no knowledge base is selected and we have some, select the first one
      if (selectedKnowledgeBaseNotifier.value == null && knowledgeBases.isNotEmpty) {
        selectedKnowledgeBaseNotifier.value = knowledgeBases.first;
      }
      
      stateNotifier.value = AiChatState.success;
    } catch (error) {
      errorMessage = error.toString();
      stateNotifier.value = AiChatState.error;
    }
  }

  /// Select a knowledge base for questioning
  void selectKnowledgeBase(KnowledgeBase knowledgeBase) {
    selectedKnowledgeBaseNotifier.value = knowledgeBase;
    // Clear previous messages when switching knowledge base
    messages.clear();
  }

  /// Get preview of a knowledge base
  Future<KnowledgeBasePreview> getKnowledgeBasePreview(String knowledgeBaseId, {int chars = 500}) async {
    try {
      return await _aiChatServices.getKnowledgeBasePreview(knowledgeBaseId, chars: chars);
    } catch (error) {
      errorMessage = error.toString();
      rethrow;
    }
  }

  /// Delete a knowledge base
  Future<void> deleteKnowledgeBase(String knowledgeBaseId) async {
    stateNotifier.value = AiChatState.loading;
    try {
      await _aiChatServices.deleteKnowledgeBase(knowledgeBaseId);
      
      // Remove from local list
      final currentList = List<KnowledgeBase>.from(knowledgeBasesNotifier.value);
      currentList.removeWhere((kb) => kb.id == knowledgeBaseId);
      knowledgeBasesNotifier.value = currentList;
      
      // If deleted knowledge base was selected, clear selection
      if (selectedKnowledgeBaseNotifier.value?.id == knowledgeBaseId) {
        selectedKnowledgeBaseNotifier.value = currentList.isNotEmpty ? currentList.first : null;
        messages.clear();
      }
      
      stateNotifier.value = AiChatState.success;
    } catch (error) {
      errorMessage = error.toString();
      stateNotifier.value = AiChatState.error;
      rethrow;
    }
  }

  /// Check API health
  Future<Map<String, dynamic>> checkHealth() async {
    try {
      return await _aiChatServices.checkHealth();
    } catch (error) {
      errorMessage = error.toString();
      rethrow;
    }
  }

  /// Clear all messages
  void clearMessages() {
    messages.clear();
  }

  /// Dispose resources
  void dispose() {
    stateNotifier.dispose();
    knowledgeBasesNotifier.dispose();
    selectedKnowledgeBaseNotifier.dispose();
  }
}
