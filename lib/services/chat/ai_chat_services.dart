import 'dart:io';
import 'package:dio/dio.dart';
import 'package:classmate/core/dio_client.dart';
import 'package:classmate/config/app_config.dart';
import 'package:classmate/models/ai_assistant/knowledge_base_model.dart';
import 'package:http_parser/http_parser.dart';

class AiChatServices {
  final DioClient dioClient = DioClient();

  /// Upload a PDF file and create a knowledge base
  Future<KnowledgeBase> uploadPdf(File pdfFile) async {
    try {
      final dio = dioClient.getDio(AppConfig.aiServer);

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          pdfFile.path,
          contentType: MediaType('application', 'pdf'),
        ),
      });

      final response = await dio.post(
        '/upload-pdf',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );

      if (response.statusCode == 200) {
        return KnowledgeBase.fromJson(response.data);
      } else {
        throw Exception('Failed to upload PDF: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error uploading PDF: $e');
    }
  }

  /// Ask a question about a specific knowledge base
  Future<QuestionResponse> askQuestion(String question, String knowledgeBaseId) async {
    try {
      final dio = dioClient.getDio(AppConfig.aiServer);

      final questionRequest = QuestionRequest(
        question: question,
        knowledgeBaseId: knowledgeBaseId,
      );

      final response = await dio.post(
        '/ask',
        data: questionRequest.toJson(),
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        return QuestionResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to get answer: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error asking question: $e');
    }
  }

  /// Get a list of all uploaded knowledge bases
  Future<List<KnowledgeBase>> getKnowledgeBases() async {
    try {
      final dio = dioClient.getDio(AppConfig.aiServer);

      final response = await dio.get('/knowledge-bases');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => KnowledgeBase.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get knowledge bases: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting knowledge bases: $e');
    }
  }

  /// Get detailed information about a specific knowledge base
  Future<KnowledgeBase> getKnowledgeBase(String knowledgeBaseId) async {
    try {
      final dio = dioClient.getDio(AppConfig.aiServer);

      final response = await dio.get('/knowledge-bases/$knowledgeBaseId');

      if (response.statusCode == 200) {
        return KnowledgeBase.fromJson(response.data);
      } else {
        throw Exception('Failed to get knowledge base: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting knowledge base: $e');
    }
  }

  /// Get a preview of the extracted text content from a knowledge base
  Future<KnowledgeBasePreview> getKnowledgeBasePreview(
    String knowledgeBaseId, {
    int chars = 1000,
  }) async {
    try {
      final dio = dioClient.getDio(AppConfig.aiServer);

      final response = await dio.get(
        '/knowledge-bases/$knowledgeBaseId/preview',
        queryParameters: {'chars': chars},
      );

      if (response.statusCode == 200) {
        return KnowledgeBasePreview.fromJson(response.data);
      } else {
        throw Exception('Failed to get knowledge base preview: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting knowledge base preview: $e');
    }
  }

  /// Delete a specific knowledge base
  Future<Map<String, dynamic>> deleteKnowledgeBase(String knowledgeBaseId) async {
    try {
      final dio = dioClient.getDio(AppConfig.aiServer);

      final response = await dio.delete('/knowledge-bases/$knowledgeBaseId');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to delete knowledge base: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting knowledge base: $e');
    }
  }

  /// Check the health status of the API
  Future<Map<String, dynamic>> checkHealth() async {
    try {
      final dio = dioClient.getDio(AppConfig.aiServer);

      final response = await dio.get('/health');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Health check failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error checking health: $e');
    }
  }
}
