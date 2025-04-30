import 'dart:convert';
import 'dart:io';

import 'package:classmate/config/app_config.dart';
import 'package:classmate/core/dio_client.dart';
import 'package:classmate/models/profile_teacher/profile_teacher_model.dart';
import 'package:dio/dio.dart';

class ProfileTeacherService {
  final dioClient = DioClient();

  Future<ProfileTeacherModel> fetchTeacherProfile() async {
    const String query = '''
    query {
      user { 
        id
        name
        email
        profile_picture
        cover_picture
        teacher {
          id
          about
          designation
          department
        }
        courses {
          id
          title
          image
        }
      }
    }
    ''';

    try {
      final response = await dioClient
          .getDio(AppConfig.graphqlServer)
          .post(
        '/',
        data: {'query': query},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['errors'] != null) {
          throw Exception('GraphQL returned errors: ${data['errors']}');
        }
        if (data['data'] != null && data['data']['user'] != null) {
          print(data['data']['user']);
          return ProfileTeacherModel.fromJson(data['data']['user']);
        } else {
          throw Exception('User data is missing');
        }
      } else {
        throw Exception('Failed to fetch teacher profile. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }

  Future<void> updateProfilePicture(File imageFile) async {
    const String mutation = '''
  mutation UpdateProfilePicture(\$image: Upload!) {
    updateProfilePicture(image: \$image) {
      id
    }
  }
  ''';

    try {
      final imageMultipart = await MultipartFile.fromFile(
        imageFile.path,
        filename: 'profile_picture.jpg',
      );

      final formData = FormData.fromMap({
        'operations': jsonEncode({
          'query': mutation,
          'variables': {'image': null},
        }),
        'map': jsonEncode({'0': ['variables.image']}),
        '0': imageMultipart,
      });

      final response = await dioClient
          .getDio(AppConfig.graphqlServer)
          .post('/', data: formData);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['errors'] != null) {
          throw Exception('GraphQL returned errors: ${data['errors']}');
        }
      } else {
        throw Exception('Failed to update profile picture. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }


  Future<void> updateCoverPhoto(File imageFile) async {
    const String mutation = '''
  mutation UpdateCoverPicture(\$image: Upload!) {
    updateCoverPicture(image: \$image) {
      id
    }
  }
  ''';
    try {
      final imageMultipart = await MultipartFile.fromFile(
        imageFile.path,
        filename: 'cover_photo.jpg',
      );
      final formData = FormData.fromMap({
        'operations': jsonEncode({
          'query': mutation,
          'variables': {'image': null},
        }),
        'map': jsonEncode({'0': ['variables.image']}),
        '0': imageMultipart,
      });
      final response = await dioClient
          .getDio(AppConfig.graphqlServer)
          .post('/', data: formData);
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['errors'] != null) {
          throw Exception('GraphQL returned errors: ${data['errors']}');
        }
      } else {
        throw Exception('Failed to update cover photo. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }















}
