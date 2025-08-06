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
        id
        title
        course_code
        enrolled_students {
          id
          roll
          name
          email
          section
          profile_picture
        }
        assignments {
          id
          title
          description
          deadline
          created_at
          submissions {
            id
            assignment_id
            student_id
            file_url
            plagiarism_score
            teacher_comments
            grade
            submitted_at
            evaluated_at
          }
        }
        classTests {
          id
          title
          description
          date
          duration
          total_marks
          created_at
        }
        schedules {
          id
          section
          room_number
          day
          start_time
          end_time
          course_id {
            id
          }
        }
      }
    }
    ''';
    try {
      
      final response = await dioClient.getDio(AppConfig.graphqlServer).post(
        '/',
        data: {'query': query},
      );

      print(response);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        
        // Check for GraphQL errors
        if (data['errors'] != null) {
          throw Exception('GraphQL errors: ${data['errors']}');
        }
        
        // Check if data and course exist
        if (data['data'] != null && data['data']['course'] != null) {
          return CourseDetailTeacherModel.fromJson(data['data']['course'] as Map<String, dynamic>);
        } else {
          throw Exception('Course data is null or missing');
        }
      } else {
        throw Exception('Failed to load course details. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }
  Future<void>createAssignment(String courseId, String title,String description,String deadline) async {
    final String mutation = '''
    mutation {
      createAssignment(assignmentInput: {
        course_id: "$courseId"
        title: "$title"
        description: "$description"
        deadline: "$deadline"
      }) {
        id
        title
        description
        deadline
        created_at
        course {
          title
          course_code
        }
      }
    }
    ''';
    
    try {
      final response = await dioClient.getDio(AppConfig.graphqlServer).post(
        '/',
        data: {'query': mutation},
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        
        if (data['errors'] != null) {
          throw Exception('GraphQL errors: ${data['errors']}');
        }
      } else {
        throw Exception('Failed to create assignment. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }

  Future<void> createClassTest(String courseId, String title, String description, String date, int duration, int totalMarks) async {
    final String mutation = '''
    mutation {
      createClassTest(classTestInput: {
        course_id: "$courseId"
        title: "$title"
        description: "$description"
        date: "$date"
        duration: $duration
        total_marks: $totalMarks
      }) {
        id
        title
        description
        date
        duration
        total_marks
        created_at
      }
    }
    ''';
    
    try {
      final response = await dioClient.getDio(AppConfig.graphqlServer).post(
        '/',
        data: {'query': mutation},
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        
        if (data['errors'] != null) {
          throw Exception('GraphQL errors: ${data['errors']}');
        }
      } else {
        throw Exception('Failed to create class test. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }
}
