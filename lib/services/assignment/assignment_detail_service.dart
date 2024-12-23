import 'package:classmate/core/dio_client.dart';
import 'package:classmate/models/submission_model.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../../config/app_config.dart';
import '../../models/assignment/assignment_detail_model.dart';

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

  Future<bool> checkAssignmentSubmission(String assignmentId) async {
    try {
      final dio = dioClient.getDio(AppConfig.mainNormalBaseUrl);

      // Make a GET request to check the submission
      final response = await dio.get('/check/check-submission/$assignmentId');

      if (response.statusCode == 200 && response.data['exists'] == true) {
        return true; // Submission exists
      } else if (response.statusCode == 404) {
        return false; // No submission found
      } else {
        throw Exception('Unexpected response: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error checking assignment submission: $e');
    }
  }


  Future<AssignmentDetailModel> getAssignmentDetails(String assignmentId) async {
    try {
      final dio = dioClient.getDio(AppConfig.graphqlServer);
      // Define the GraphQL query
      const String query = r'''
    query GetAssignmentDetails($id: ID!) {
      assignment(id: $id) {
        id
        title
        description
        submission {
          plagiarism_score
          grade
          ai_generated
          teacher_comments
        }
      }
    }
    ''';

      // Make the POST request to the GraphQL endpoint
      final response = await dio.post(
        '/',
        data: {
          'query': query,
          'variables': {'id': assignmentId},
        },
      );

      // Check if the response is successful
      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data != null && data['assignment'] != null) {
          return AssignmentDetailModel.fromJson(data);
        } else {
          throw Exception('Assignment not found.');
        }
      } else {
        throw Exception(
            'Failed to fetch assignment details. Server responded with ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching assignment details: $e');
    }
  }

}
