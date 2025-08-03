import 'package:classmate/config/app_config.dart';
import 'package:classmate/core/dio_client.dart';
import 'package:classmate/models/home_teacher/teacher_dashboard_model.dart';

class TeacherDashboardService {
  final DioClient _dioClient = DioClient();

  Future<TeacherDashboardModel?> getMyCreatedCourses() async {
    try {
      const String query = '''
        query GetMyCreatedCourses {
          user {
            courses {
              id
              title
              course_code
              description
              credit
              excerpt
              image
              created_at
              enrolled
            }
          }
        }
      ''';

      final response = await _dioClient.getDio(AppConfig.graphqlServer).post(
        '/',
        data: {
          'query': query,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['errors'] != null) {
          throw Exception('GraphQL Error: ${data['errors']}');
        }
        
        if (data['data'] != null) {
          return TeacherDashboardModel.fromJson(data['data']);
        }
      }
      
      return null;
    } catch (e) {
      print('Error fetching teacher courses: $e');
      rethrow;
    }
  }
}