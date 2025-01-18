import 'package:classmate/config/app_config.dart';
import 'package:classmate/core/dio_client.dart';
import 'package:classmate/models/explore/explore_course_model.dart';

class ExploreCourseService {
  final dioClient = DioClient();

  Future<List<ExploreCourseModel>> searchCourses(String keyword) async {
    try {
      final dio = dioClient.getDio(AppConfig.graphqlServer);
      const String query = r'''
      query SearchCourses($keyword: String!) {
        searchCourses(keyword: $keyword) {
          id
          title
          course_code
          description
        }
      }
      ''';
      final response = await dio.post(
        '/',
        data: {
          'query': query,
          'variables': {'keyword': keyword},
        },
      );

      // Check for errors in response
      if (response.data['errors'] != null) {
        throw Exception(response.data['errors']);
      }

      // Map response to ExploreCourseModel list
      final courses = (response.data['data']['searchCourses'] as List<dynamic>)
          .map((course) => ExploreCourseModel.fromJson(course as Map<String, dynamic>))
          .toList();
      return courses;
    } catch (e) {
      // print('Error searching courses: $e');
      throw Exception('Failed to search courses.');
    }
  }

}
