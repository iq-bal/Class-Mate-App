import 'package:classmate/config/app_config.dart';
import 'package:classmate/core/token_storage.dart';
import 'package:classmate/core/dio_client.dart';
import 'package:classmate/graphql/course_detail_teacher/graphql_queries.dart';
import 'package:classmate/models/course_detail_teacher/course_detail_teacher_model.dart';
import 'package:dio/dio.dart';

class CourseDetailTeacherService {
  final dioClient = DioClient();
  Future<CourseDetailTeacherModel> getCourseDetails(String courseId) async {
    final String query = '''
    query {
      course(id: "$courseId") {
        title
        course_code
        enrolled_students {
          uid
          email
          name
          role
        }
        assignments {
          id
          title
          description
          deadline
          created_at
        }
        schedule{
          section
          room_no
          day
          start_time
          end_time
        }
      }
    }
    ''';
    try {
      final response = await dioClient.getDio(AppConfig.mainServerBaseUrl).post(
        '/graphql',
        data: {'query': query},
      );

      if (response.statusCode == 200 && response.data != null) {
        return CourseDetailTeacherModel.fromJson(response.data['data']['course']);
      } else {
        throw Exception('Failed to load course details');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }
}
