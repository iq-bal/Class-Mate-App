import 'package:classmate/config/app_config.dart';
import 'package:classmate/core/dio_client.dart';
import 'package:classmate/models/assignment_teacher/submission_detail_model.dart';

class AssignmentTeacherServices {
  final dioClient = DioClient();

  Future<SubmissionDetailModel> getAssignmentSubmissions(String assignmentId) async {



    const String query = '''
    query GetAssignmentSubmissions(\$assignmentId: ID!) {
      submissionsByAssignment(assignment_id: \$assignmentId) {
        id
        file_url
        plagiarism_score
        ai_generated
        teacher_comments
        grade
        submitted_at
        evaluated_at
        student {
          id
          name
          email
          roll
          section
          profile_picture
        }
        assignment_id {
          id
          title
          description
          deadline
        }
      }
    }
    ''';

    try {
      final variables = {'assignmentId': assignmentId};



      final response = await dioClient
          .getDio(AppConfig.graphqlServer)
          .post(
        '/',
        data: {'query': query, 'variables': variables},
      );



      if (response.statusCode == 200) {


        final data = response.data;



        // Check if the response contains GraphQL errors.
        if (data['errors'] != null) {

          throw Exception('GraphQL returned errors: ${data['errors']}');
        }


        // Ensure data is not null.
        if (data['data'] != null) {
          return SubmissionDetailModel.fromJson(data);
        } else {
          throw Exception('Response data is null');
        }
      } else {
        throw Exception('Failed to fetch assignment submissions. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }
}
