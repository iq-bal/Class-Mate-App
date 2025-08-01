import 'package:classmate/config/app_config.dart';
import 'package:classmate/core/dio_client.dart';
import 'package:classmate/models/course_overview/course_overview_model.dart';

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
}