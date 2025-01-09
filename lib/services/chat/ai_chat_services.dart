import 'dart:convert';
import 'dart:io';
import 'package:classmate/config/app_config.dart';
import 'package:dio/dio.dart';
import 'package:classmate/core/dio_client.dart';
import 'package:http_parser/http_parser.dart';

class AiChatServices {
  final DioClient dioClient = DioClient();

  // Upload PDF using Dio
  Future<Map<String, dynamic>> uploadPdf(File pdfFile) async {
    try {
      final dio = dioClient.getDio(AppConfig.aiServer);

      print('File path: ${pdfFile.path}');
      print('File exists: ${await pdfFile.exists()}');
      print('File size: ${await pdfFile.length()} bytes');

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          pdfFile.path,
          contentType: MediaType('application', 'pdf'),
        ),
      });

      final response = await dio.post(
        '/upload-pdf',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      if (response.statusCode == 200) {
        print('Upload successful: ${response.data}');
        return response.data;
      } else {
        print('Upload failed: ${response.data}');
        throw Exception('Failed to upload PDF: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading PDF: $e');
      rethrow;
    }
  }

  // Ask a question using Dio
  Future<String> askQuestion(String question) async {
    try {
      final dio = dioClient.getDio(AppConfig.aiServer);

      final response = await dio.post(
        '/ask',
        data: {'question': question},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        print('Response data: $data');
        return data['answer'] ?? 'No answer found';
      } else {
        print('Failed to get answer: ${response.data}');
        throw Exception('Failed to get answer: ${response.statusCode}');
      }
    } catch (e) {
      print('Error asking question: $e');
      rethrow;
    }
  }
}
