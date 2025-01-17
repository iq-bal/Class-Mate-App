import 'package:classmate/config/app_config.dart';
import 'package:classmate/core/token_storage.dart';
import 'package:classmate/core/dio_client.dart';
import 'package:classmate/graphql/course_detail_teacher/graphql_queries.dart';
import 'package:classmate/models/course_detail_teacher/course_detail_teacher_model.dart';
import 'package:dio/dio.dart';

class CourseDetailTeacherService {
  final dioClient = DioClient();
  Future<CourseDetailTeacherModel> getCourseDetails(String courseId,String section,String day) async {
    final String query = '''
    query {
      course(id: "$courseId") {
        title
        course_code
        enrolled_students(section: "$section"){
          id
          roll
          name
          email
          section
        }
        assignments {
          id
          title
          description
          deadline
          created_at
          submissions{
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
        schedule(section: "$section",day:"$day"){
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
  Future<void>createAssignment(String courseId, String title,String description,String deadline) async {
      try{
        final response = await dioClient.getDio(AppConfig.mainNormalBaseUrl).post(
            '/create/create-assignment?courseId=$courseId',
          data: {
            'title': title,
            'description': description,
            'deadline': deadline
          }
        );
      }catch(e){
          throw Exception('Error occurred: $e');
      }
  }
}
