import 'package:classmate/config/app_config.dart';
import 'package:classmate/core/dio_client.dart';
import 'package:classmate/models/class_details_student/class_details_student_model.dart';
import 'package:dio/dio.dart';

class ClassDetailsStudentServices {
  final dioClient = DioClient();

  Future<ClassDetailsStudentModel> getClassDetails(String courseId, String day, String teacherId) async {
    const String query = '''
    query getClassDetails(\$id: ID!, \$day: String!, \$teacherId: ID!) {
      course(id: \$id) {
        id
        title
        course_code
        schedule(day: \$day, teacher_id: \$teacherId) {
          day
          room_number
          section
          start_time
          end_time
        }
        sessions {
          attendance {
            status
          }
        }
        assignments {
          id
          title
          description
          deadline
          submissionCount
        }
      }
    }
    ''';

    try {
      final variables = {'id': courseId, 'day': day, 'teacherId': teacherId};
      final response = await dioClient.getDio(AppConfig.graphqlServer).post(
        '/',
        data: {'query': query, 'variables': variables},
      );
      print("student class details start");
      print(response);
      print("end");
      if (response.statusCode == 200) {
        final data = response.data;
        // Check for errors in the response
        if (data['errors'] != null) {
          throw Exception('GraphQL returned errors: ${data['errors']}');
        }
        // Ensure data is not null
        if (data['data'] != null) {
          return ClassDetailsStudentModel.fromJson(data['data']);
        } else {
          throw Exception('Response data is null');
        }
      } else {
        throw Exception('Failed to fetch class details. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }
}
