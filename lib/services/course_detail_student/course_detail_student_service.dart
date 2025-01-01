import 'package:classmate/config/app_config.dart';
import 'package:classmate/core/dio_client.dart';
import 'package:classmate/models/course_detail_student/course_detail_student_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

class CourseDetailStudentService {
  final DioClient dioClient = DioClient();



  Future<CourseDetailStudentModel?> getCourseDetailsAndSyllabuses(String courseId) async {
    const String query = """
  query getSyllabus(\$id: ID!) {
    course(id: \$id) {
      title
      description
      teacher {
        name
      }
      syllabus {
        id
        syllabus
      }
      enrollment {
        status
      }
    }
  }
  """;

    try {
      final Dio dio = dioClient.getDio(AppConfig.graphqlServer);

      final Response response = await dio.post(
        '/',
        data: {
          'query': query,
          'variables': {'id': courseId},
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['errors'] != null) {
          // print("Error in GraphQL response: ${data['errors']}");
          return null;
        } else {
          final courseData = data['data']['course'];
          return CourseDetailStudentModel.fromJson(courseData);
        }
      } else {
        // print("Failed to fetch course details. Status code: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error during fetching course details: $e");
      return null;
    }
  }





  Future<void> enroll(String courseId) async {
    const String query = """
    mutation AddEnrollment(\$courseId: ID!) {
      addEnrollment(course_id: \$courseId) {
        id
        status
      }
    }
    """;

    try {
      // Get the Dio instance configured for the GraphQL server
      final Dio dio = dioClient.getDio(AppConfig.graphqlServer);

      // Make the POST request
      final Response response = await dio.post(
        '/',
        data: {
          'query': query,
          'variables': {'courseId': courseId},
        },
      );

      // Check the response for success or errors
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['errors'] != null) {
          print("Error in GraphQL response: ${data['errors']}");
        } else {
          print("Enrollment successful: ${data['data']['addEnrollment']}");
        }
      } else {
        print("Failed to enroll. Status code: ${response.statusCode}");
      }
    } catch (e) {
      // Catch and log the error
      print("Error during enrollment: $e");
    }
  }
}