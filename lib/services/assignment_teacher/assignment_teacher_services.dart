import 'package:classmate/config/app_config.dart';
import 'package:classmate/core/dio_client.dart';
import 'package:classmate/models/assignment_teacher/submission_detail_model.dart';
import 'package:classmate/models/assignment_teacher/evaluation_model.dart';

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
        if (data['errors'] != null) {
          throw Exception('GraphQL returned errors: ${data['errors']}');
        }
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



  // New function for the GetSubmission query.
  Future<EvaluationModel> getSingleSubmission(String assignmentId, String studentId) async {
    const String query = '''
    query GetSubmission(\$assignmentId: ID!, \$studentId: ID!) {
      getSubmissionByAssignmentAndStudent(assignment_id: \$assignmentId, student_id: \$studentId) {
        id
        file_url
        plagiarism_score
        ai_generated
        teacher_comments
        grade
        student {
          id
          name
          email
          profile_picture
          roll
          section
        }
        assignment_id {
          id
          title
          description
          deadline
          teacher {
            id
            name
            profile_picture
          }
        }
      }
    }
    ''';

    try {
      final variables = {
        'assignmentId': assignmentId,
        'studentId': studentId,
      };

      final response = await dioClient
          .getDio(AppConfig.graphqlServer)
          .post(
        '/',
        data: {'query': query, 'variables': variables},
      );



      if (response.statusCode == 200) {
        final data = response.data;
        if (data['errors'] != null) {
          throw Exception('GraphQL returned errors: ${data['errors']}');
        }
        if (data['data'] != null) {
          return EvaluationModel.fromJson(data);
        } else {
          throw Exception('Response data is null');
        }
      } else {
        throw Exception('Failed to fetch submission. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }


}
