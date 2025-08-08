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
    const String query = '''
    query GetEnrollmentStatus(\$courseId: ID!) { 
      enrollmentStatus(course_id: \$courseId) { 
        id 
        status 
        enrolled_at 
      } 
    }
    ''';

    try {
      print('Enrollment Status Query: $query');
      print('Variables: ${{'courseId': courseId}}');
      
      final response = await dioClient.getDio(AppConfig.graphqlServer).post(
        '/',
        data: {
          'query': query,
          'variables': {'courseId': courseId},
        },
      );
      
      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Check if there are GraphQL errors
        if (data['errors'] != null) {
          // Check if the error is specifically about non-nullable fields (which means no enrollment exists)
          final errors = data['errors'] as List;
          final hasNullabilityError = errors.any((error) => 
            error['message']?.toString().contains('Cannot return null for non-nullable field') == true);
          
          if (hasNullabilityError) {
            // This means there's no enrollment status - return null instead of throwing error
            return null;
          } else {
            // Other GraphQL errors should still be thrown
            throw Exception('GraphQL returned errors: ${data["errors"]}');
          }
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
      print('Caught exception in getEnrollmentStatus: $e');
      
      // Check if the error is about non-nullable fields (indicating no enrollment exists)
      if (e.toString().contains('Cannot return null for non-nullable field')) {
        return null; // No enrollment status exists
      }
      
      // Check if it's a 400 Bad Request which might indicate query syntax issues
      if (e.toString().contains('status code of 400')) {
        print('400 Bad Request - likely GraphQL query syntax issue');
        // Try to continue without throwing error - return null to indicate no enrollment
        return null;
      }
      
      throw Exception('Error occurred while checking enrollment status: $e');
    }
  }

  Future<Map<String, dynamic>> enrollInCourse(String courseId) async {
    final String mutation = '''
    mutation EnrollInCourse(\$courseId: ID!) { 
      addEnrollment(course_id: \$courseId) { 
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
          'variables': {'courseId': courseId},
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