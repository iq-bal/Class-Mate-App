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

  Future<CourseModel?> updateCourse({
    required String courseId,
    required String title,
    required String courseCode,
    required String description,
    required int credit,
    required String excerpt,
    required Map<String, List<String>> syllabus,
  }) async {
    try {
      const String mutation = '''
        mutation UpdateCourse(\$id: ID!, \$input: CourseUpdateInput!) {
          updateCourse(id: \$id, input: \$input) {
            id
            title
            course_code
            description
            credit
            excerpt
            image
            created_at
            syllabus {
              id
              syllabus
            }
          }
        }
      ''';

      final variables = {
        'id': courseId,
        'input': {
          'title': title,
          'course_code': courseCode,
          'description': description,
          'credit': credit,
          'excerpt': excerpt,
          'syllabus': syllabus,
        },
      };

      final response = await _dioClient.getDio(AppConfig.graphqlServer).post(
        '/',
        data: {
          'query': mutation,
          'variables': variables,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['errors'] != null) {
          throw Exception('GraphQL Error: ${data['errors']}');
        }
        
        if (data['data'] != null && data['data']['updateCourse'] != null) {
          // Convert the response to CourseModel format
          final courseData = data['data']['updateCourse'];
          final convertedData = {
            'id': courseData['id'],
            'title': courseData['title'],
            'course_code': courseData['course_code'],
            'description': courseData['description'],
            'credit': courseData['credit'],
            'excerpt': courseData['excerpt'],
            'image': courseData['image'],
            'created_at': courseData['created_at'],
            'enrolled': 0, // This might need to be fetched separately or included in mutation response
          };
          return CourseModel.fromJson(convertedData);
        }
      }
      
      return null;
    } catch (e) {
      print('Error updating course: $e');
      rethrow;
    }
  }
}