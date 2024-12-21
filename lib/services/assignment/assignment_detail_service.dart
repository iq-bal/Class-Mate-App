import 'package:classmate/core/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../../config/app_config.dart';

class AssignmentDetailService{
  final dioClient = DioClient();
  Future<void> submitAssignmentWithFile(String assignmentId, String filePath) async {
    try {
      final dio = dioClient.getDio(AppConfig.mainNormalBaseUrl);
      final file = await MultipartFile.fromFile(
        filePath,
        filename: filePath.split('/').last,
        contentType: MediaType('application', 'pdf'), // Explicitly set to application/pdf
      );
      final formData = FormData.fromMap({
        'file': file,
      });
      final response = await dio.post(
        '/submit/submit-assignment/$assignmentId',
        data: formData,
      );
      if (response.statusCode!=201) {
        throw Exception('Failed to submit assignment. Server responded with ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error submitting assignment: $e');
    }
  }
}
