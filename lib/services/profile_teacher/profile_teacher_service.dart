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

  Future<String> updateProfilePicture(File imageFile) async {
    const String mutation = '''
  mutation UpdateProfilePicture(\$image: Upload!) {
    updateProfilePicture(image: \$image) {
      id
      profile_picture
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

        // Extract the new URL from the response
        final updated = data['data']['updateProfilePicture'];
        final newUrl = updated['profile_picture'] as String?;
        if (newUrl == null) {
          throw Exception('Profile picture field missing in response');
        }

        return newUrl;
      } else {
        throw Exception('Failed to update profile picture. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }


  Future<String> updateCoverPhoto(File imageFile) async {
    const String mutation = '''
  mutation UpdateCoverPicture(\$image: Upload!) {
    updateCoverPicture(image: \$image) {
      id
      cover_picture
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
        final updated = data['data']['updateCoverPicture'];
        final newUrl = updated['cover_picture'] as String?;
        if (newUrl == null) {
          throw Exception('Profile picture field missing in response');
        }
        return newUrl;
      } else {
        throw Exception('Failed to update cover photo. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }



  /// Updates only the `about` field of the teacher.
  Future<void> updateTeacherAbout(String about) async {
    const String mutation = '''
    mutation UpdateTeacher(\$teacherInput: TeacherInput!) {
      updateTeacher(teacherInput: \$teacherInput) {
        id
      }
    }
  ''';

    final variables = {
      'teacherInput': {
        'about': about,
      },
    };

    final response = await dioClient
        .getDio(AppConfig.graphqlServer)
        .post('/', data: {
      'query': mutation,
      'variables': variables,
    });

    if (response.statusCode != 200 || response.data['errors'] != null) {
      throw Exception(
        'Failed to update about: ${response.data['errors'] ?? response.statusCode}',
      );
    }
  }

  /// Updates only the `department` field of the teacher.
  Future<void> updateTeacherDepartment(String department) async {
    const String mutation = '''
    mutation UpdateTeacher(\$teacherInput: TeacherInput!) {
      updateTeacher(teacherInput: \$teacherInput) {
        id
      }
    }
  ''';

    final variables = {
      'teacherInput': {
        'department': department,
      },
    };

    final response = await dioClient
        .getDio(AppConfig.graphqlServer)
        .post('/', data: {
      'query': mutation,
      'variables': variables,
    });

    if (response.statusCode != 200 || response.data['errors'] != null) {
      throw Exception(
        'Failed to update department: ${response.data['errors'] ?? response.statusCode}',
      );
    }
  }

  /// Updates only the `designation` field of the teacher.
  Future<void> updateTeacherDesignation(String designation) async {
    const String mutation = '''
    mutation UpdateTeacher(\$teacherInput: TeacherInput!) {
      updateTeacher(teacherInput: \$teacherInput) {
        id
      }
    }
  ''';

    final variables = {
      'teacherInput': {
        'designation': designation,
      },
    };

    final response = await dioClient
        .getDio(AppConfig.graphqlServer)
        .post('/', data: {
      'query': mutation,
      'variables': variables,
    });

    if (response.statusCode != 200 || response.data['errors'] != null) {
      throw Exception(
        'Failed to update designation: ${response.data['errors'] ?? response.statusCode}',
      );
    }
  }

  /// Deletes a course with the given ID
  Future<void> deleteCourse(String courseId) async {
    const String mutation = '''
    mutation DeleteCourse(\$id: ID!) {
      deleteCourse(id: \$id) {
        id
        title
        course_code
      }
    }
    ''';

    try {
      final response = await dioClient.getDio(AppConfig.graphqlServer).post(
        '/',
        data: {
          'query': mutation,
          'variables': {'id': courseId},
        },
      );

      final data = response.data;
      if (data == null) {
        throw Exception('No response data received');
      }

      if (data['errors'] != null) {
        final errors = data['errors'] as List<dynamic>;
        final errorMessage = errors.map((e) => e['message']).join(', ');
        throw Exception('GraphQL errors: $errorMessage');
      }

      if (!data.containsKey('data') || data['data'] == null || !data['data'].containsKey('deleteCourse')) {
        throw Exception('Invalid response format: Missing deleteCourse data');
      }

      final deletedCourse = data['data']['deleteCourse'];
      if (deletedCourse == null) {
        throw Exception('Course deletion failed: No course data returned');
      }
    } catch (e) {
      if (e.toString().contains('DioException')) {
        throw Exception('Network error while deleting course. Please check your connection and try again.');
      }
      throw Exception('Error deleting course: $e');
    }
  }
}
