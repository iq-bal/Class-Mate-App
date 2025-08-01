import 'package:dio/dio.dart';
import 'package:classmate/core/dio_client.dart';
import 'package:classmate/config/app_config.dart';
import 'package:classmate/models/course_detail_teacher/enrollment_model.dart';

class EnrollmentService {
  final DioClient _dioClient = DioClient();

  Future<List<EnrollmentModel>> getCourseEnrollments(String courseId) async {
    final String query = '''
      query {
        courseEnrollments(course_id: "$courseId") {
          id
          status
          enrolled_at
          student {
            id
            roll
            section
            name
            email
            profile_picture
          }
        }
      }
    ''';

    try {
      final dio = _dioClient.getDio(AppConfig.graphqlServer);
      final response = await dio.post(
        '/',
        data: {
          'query': query,
        },
      );

      if (response.data == null) {
        throw Exception('No data received from server');
      }

      final data = response.data as Map<String, dynamic>;
      
      if (data['errors'] != null) {
        throw Exception('GraphQL Error: ${data['errors']}');
      }

      if (data['data'] == null || data['data']['courseEnrollments'] == null) {
        throw Exception('Invalid response structure');
      }

      final enrollmentsData = data['data']['courseEnrollments'] as List;
      
      return enrollmentsData
          .map((enrollment) => EnrollmentModel.fromJson(enrollment))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch course enrollments: $e');
    }
  }

  Future<bool> updateEnrollmentStatus(String enrollmentId, String status) async {
    final String mutation = '''
      mutation {
        updateEnrollmentStatusByTeacher(
          enrollment_id: "$enrollmentId"
          status: "$status"
        ) {
          id
          status
          enrolled_at
        }
      }
    ''';

    try {
      final dio = _dioClient.getDio(AppConfig.graphqlServer);
      final response = await dio.post(
        '/',
        data: {
          'query': mutation,
        },
      );

      if (response.data == null) {
        throw Exception('No data received from server');
      }

      final data = response.data as Map<String, dynamic>;
      
      if (data['errors'] != null) {
        throw Exception('GraphQL Error: ${data['errors']}');
      }

      if (data['data'] == null || data['data']['updateEnrollmentStatusByTeacher'] == null) {
        throw Exception('Invalid response structure');
      }

      return true;
    } catch (e) {
      throw Exception('Failed to update enrollment status: $e');
    }
  }
}