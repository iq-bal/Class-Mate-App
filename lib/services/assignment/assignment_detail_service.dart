import 'package:classmate/core/dio_client.dart';
import 'package:classmate/models/assignment/evaluation_model.dart';
import 'package:classmate/models/submission_model.dart';
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

  // Check if an assignment submission exists and return EvaluationModel
  Future<EvaluationModel?> checkAssignmentSubmission(String assignmentId) async {
    try {
      final dio = dioClient.getDio(AppConfig.mainNormalBaseUrl);

      // Make a GET request to check the submission
      final response = await dio.get('/check/check-submission/$assignmentId');

      if (response.statusCode == 200 && response.data['exists'] == true) {
        // Parse the submission data into an EvaluationModel object
        return EvaluationModel.fromJson(response.data['submission']);
      } else if (response.statusCode == 404) {
        // No submission found, return null
        return null;
      } else {
        throw Exception('Unexpected response: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error checking assignment submission: $e');
    }
  }

}
