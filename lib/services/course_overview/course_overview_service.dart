import 'package:classmate/config/app_config.dart';
import 'package:classmate/core/dio_client.dart';
import 'package:classmate/models/course_overview/course_overview_model.dart';
import 'package:classmate/models/enrollment/enrollment_status_model.dart';

class CourseOverviewService {
  final dioClient = DioClient();

  Future<CourseOverviewModel> getCourseOverview(String courseId) async {
    const String query = '''
    query CourseOverview(\$courseId: ID!) {
      course(id: \$courseId) {
        id
        title
        description
        image
        credit
        averageRating
        teacher {
          id
          user_id {
            name
            profile_picture
          }
          about
          designation
        }
        syllabus {
          syllabus
        }
        reviews {
          id
          rating
          comment
          createdAt
          commented_by {
            name
            profile_picture
          }
        }
      }
    }
    ''';

    try {
      final response = await dioClient.getDio(AppConfig.graphqlServer).post(
        '/',
        data: {
          'query': query,
          'variables': {'courseId': courseId},
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['errors'] != null) {
          throw Exception('GraphQL returned errors: ${data['errors']}');
        }
        if (data['data'] != null && data['data']['course'] != null) {
          return CourseOverviewModel.fromJson(data['data']['course']);
        } else {
          throw Exception('Course data is missing');
        }
      } else {
        throw Exception('Failed to fetch course overview. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }

  Future<EnrollmentStatusModel?> getEnrollmentStatus(String courseId) async {
    final String query = '''
    query { 
      enrollmentStatus(course_id: "$courseId") { 
        id 
        status 
        enrolled_at 
      } 
    }
    ''';

    try {
      final response = await dioClient.getDio(AppConfig.graphqlServer).post(
        '/',
        data: {
          'query': query,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['errors'] != null) {
          throw Exception('GraphQL returned errors: ${data["errors"]}');
        }
        if (data['data'] != null && data['data']['enrollmentStatus'] != null) {
          return EnrollmentStatusModel.fromJson(data['data']['enrollmentStatus']);
        } else {
          return null; // No enrollment status found
        }
      } else {
        throw Exception('Failed to get enrollment status. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred while checking enrollment status: $e');
    }
  }

  Future<Map<String, dynamic>> enrollInCourse(String courseId) async {
    final String mutation = '''
    mutation { 
      addEnrollment(course_id: "$courseId") { 
        id 
        status 
      } 
    }
    ''';

    try {
      final response = await dioClient.getDio(AppConfig.graphqlServer).post(
        '/',
        data: {
          'query': mutation,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['errors'] != null) {
          throw Exception('GraphQL returned errors: ${data["errors"]}');
        }
        if (data['data'] != null && data['data']['addEnrollment'] != null) {
          return data['data']['addEnrollment'];
        } else {
          throw Exception('Enrollment data is missing');
        }
      } else {
        throw Exception('Failed to enroll in course. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred during enrollment: $e');
    }
  }
}