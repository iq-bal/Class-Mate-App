import 'dart:io';
import 'package:dio/dio.dart';
import 'package:classmate/models/quiz/question_generator_model.dart';

class QuestionGeneratorService {
  static const String baseUrl = 'http://localhost:8001'; // Question generator server URL
  late final Dio _dio;

  QuestionGeneratorService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    ));
  }

  /// Generate questions from PDF file
  Future<QuestionGeneratorModel?> generateQuestions({
    required File pdfFile,
    int numQuestions = 5,
    String difficulty = 'medium',
    String testTitle = 'Generated Quiz',
  }) async {
    try {
      // Create form data
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          pdfFile.path,
          filename: pdfFile.path.split('/').last,
        ),
        'num_questions': numQuestions.toString(),
        'difficulty': difficulty,
        'test_title': testTitle,
      });

      // Make request to public endpoint (no auth required for demo)
      final response = await _dio.post(
        '/generate-questions-public',
        data: formData,
      );

      if (response.statusCode == 200 && response.data != null) {
        return QuestionGeneratorModel.fromJson(response.data);
      }

      return null;
    } on DioException catch (e) {
      print('DioException generating questions: ${e.message}');
      if (e.response != null) {
        print('Response data: ${e.response?.data}');
        print('Response status: ${e.response?.statusCode}');
      }
      rethrow;
    } catch (e) {
      print('Error generating questions: $e');
      rethrow;
    }
  }

  /// Check if the question generator service is available
  Future<bool> checkHealth() async {
    try {
      final response = await _dio.get('/health');
      return response.statusCode == 200;
    } catch (e) {
      print('Question generator service health check failed: $e');
      return false;
    }
  }

  /// Get service info
  Future<Map<String, dynamic>?> getServiceInfo() async {
    try {
      final response = await _dio.get('/');
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      print('Error getting service info: $e');
      return null;
    }
  }
}
