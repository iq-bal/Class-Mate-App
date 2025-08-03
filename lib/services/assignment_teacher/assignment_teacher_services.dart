import 'package:classmate/config/app_config.dart';
import 'package:classmate/core/dio_client.dart';
import 'package:classmate/models/assignment_teacher/submission_detail_model.dart';
import 'package:classmate/models/assignment_teacher/evaluation_model.dart';

class AssignmentTeacherServices {
  final dioClient = DioClient();

  Future<SubmissionDetailModel> getAssignmentSubmissions(String assignmentId) async {
    const String query = '''
    query GetAssignmentWithSubmissions(\$assignmentId: ID!) {
      assignment(id: \$assignmentId) {
        id
        title
        description
        deadline
        created_at
        course {
          id
          title
          course_code
        }
        submissions {
          id
          assignment_id
          student_id
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
            profile_picture
            roll
            section
          }
        }
        submissionCount
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



  // Updated function for the GetSubmissionById query.
  Future<EvaluationModel> getSingleSubmission(String submissionId) async {
    const String query = '''
    query GetSubmissionById(\$submissionId: ID!) {
      submission(id: \$submissionId) {
        id
        assignment_id
        student_id
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
          profile_picture
          roll
          section
        }
        assignment {
          id
          title
          description
          deadline
          created_at
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
        'submissionId': submissionId,
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


  Future<void> updateSubmission(String submissionId, Map<String, dynamic> submissionInput) async {

    // Only keep 'grade' and 'teacher_comments' from the input
    final filteredSubmissionInput = {
      'grade': submissionInput['grade'],
      'teacher_comments': submissionInput['teacher_comments'],
    };


    const String mutation = '''
  mutation UpdateSubmission(\$id: ID!, \$submissionInput: UpdateSubmissionInput!) {
    updateSubmission(id: \$id, submissionInput: \$submissionInput) {
      id
    }
  }
  ''';

    try {
      final variables = {
        'id': submissionId,
        'submissionInput': filteredSubmissionInput, // Pass only the filtered input
      };

      final response = await dioClient
          .getDio(AppConfig.graphqlServer)
          .post(
        '/',
        data: {'query': mutation, 'variables': variables},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update submission. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }


}
