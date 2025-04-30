import 'package:classmate/config/app_config.dart';
import 'package:classmate/core/dio_client.dart';
import 'package:classmate/models/create_course/syllabus_model.dart';

class SyllabusService {
  final dioClient = DioClient();

  Future<SyllabusModel> updateSyllabus({
    required String courseId,
    required Map<String, List<String>> syllabusData,
  }) async {
    // print(syllabusData);
    const String mutation = r'''
    mutation UpdateSyllabus($courseId: ID!, $syllabusData: JSON!) {
      updateSyllabus(course_id: $courseId, syllabus: $syllabusData) {
        id
        course_id
        syllabus
      }
    }
    ''';

    final variables = {
      'courseId': courseId,
      'syllabusData': syllabusData,
    };

    try {
      final response = await dioClient.getDio(AppConfig.graphqlServer).post(
        '/',
        data: {
          'query': mutation,
          'variables': variables,
        },
      );

      if (response.statusCode == 200) {
        final body = response.data;
        if (body['errors'] != null) {
          throw Exception('GraphQL errors: ${body['errors']}');
        }
        final data = body['data']?['updateSyllabus'];
        if (data != null) {
          return SyllabusModel.fromJson(data);
        } else {
          throw Exception('No data received for updateSyllabus');
        }
      } else {
        throw Exception('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update syllabus: $e');
    }
  }
}
