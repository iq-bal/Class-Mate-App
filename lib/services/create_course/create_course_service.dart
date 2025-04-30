import 'dart:convert';
import 'dart:io';
import 'package:classmate/config/app_config.dart';
import 'package:classmate/core/dio_client.dart';
import 'package:classmate/models/create_course/create_course_model.dart';
import 'package:dio/dio.dart';

class CreateCourseService {
  final dioClient = DioClient();

  Future<CreateCourseModel> createCourse({
    required String title,
    required String courseCode,
    required double credit,
    required String description,
    String? excerpt,
    File? imageFile,
  }) async {
    const String mutation = '''
      mutation CreateCourse(
        \$title: String!
        \$course_code: String!
        \$credit: Float!
        \$description: String!
        \$excerpt: String
        \$image: Upload
      ) {
        createCourse(
          title: \$title
          course_code: \$course_code
          credit: \$credit
          description: \$description
          excerpt: \$excerpt
          image: \$image
        ) {
          id
          title
          course_code
          credit
          description
          excerpt
          image
        }
      }
    ''';
    MultipartFile? imageMultipart;
    if (imageFile != null) {
      try {
        imageMultipart = await MultipartFile.fromFile(
          imageFile.path,
          filename: 'course_image.jpg',
        );
      } catch (e) {
        print("Error creating MultipartFile: $e");
      }
    }
    final formData = FormData.fromMap({
      'operations': jsonEncode({
        'query': mutation,
        'variables': {
          'title': title,
          'course_code': courseCode,
          'credit': credit,
          'description': description,
          'excerpt': excerpt,
          'image': null,
        },
      }),
      'map': jsonEncode({
        '0': ['variables.image'],
      }),
      '0': imageMultipart,
    });


    final response = await dioClient.getDio(AppConfig.graphqlServer).post('/', data: formData);

    if (response.statusCode == 200) {
      final data = response.data;
      if (data['errors'] != null) {
        throw Exception('GraphQL returned errors: ${data['errors']}');
      }
      return CreateCourseModel.fromJson(data['data']['createCourse']);
    } else {
      throw Exception('Failed to create course. Status code: ${response.statusCode}');
    }
  }
}
