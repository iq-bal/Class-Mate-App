import 'dart:convert';
import 'dart:io';

import 'package:classmate/config/app_config.dart';
import 'package:classmate/core/dio_client.dart';
import 'package:classmate/models/profile_student/profile_student_model.dart';
import 'package:dio/dio.dart';

class ProfileStudentService {
  final dioClient = DioClient();

  Future<ProfileStudentModel> fetchStudentProfile() async {
    const String query = '''
    query GetStudentProfile {
      currentStudent {
        id
        roll
        section
        name
        email
        profile_picture
        about
        department
        semester
        cgpa
        user_id {
          id
          name
          email
          profile_picture
          cover_picture
        }
        enrollments {
          id
          status
          enrolled_at
          courses {
            id
            title
            course_code
            description
            image
            credit
          }
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
        if (data['data'] != null && data['data']['currentStudent'] != null) {
          return ProfileStudentModel.fromJson(data['data']['currentStudent']);
        } else {
          throw Exception('Student data is missing');
        }
      } else {
        throw Exception('Failed to fetch student profile. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }

  Future<String> updateProfilePicture(File imageFile) async {
    const String mutation = '''
  mutation UpdateStudentProfilePicture(\$image: Upload!) {
    updateStudentProfilePicture(image: \$image) {
      id
      name
      email
      profile_picture
      user_id {
        id
        name
        profile_picture
        cover_picture
      }
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

        final updated = data['data']['updateStudentProfilePicture'];
        final newUrl = updated['user_id']['profile_picture'] as String?;
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
  mutation UpdateStudentCoverPicture(\$image: Upload!) {
    updateStudentCoverPicture(image: \$image) {
      id
      name
      email
      profile_picture
      user_id {
        id
        name
        profile_picture
        cover_picture
      }
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
        final updated = data['data']['updateStudentCoverPicture'];
        final newUrl = updated['user_id']['cover_picture'] as String?;
        if (newUrl == null) {
          throw Exception('Cover picture field missing in response');
        }
        return newUrl;
      } else {
        throw Exception('Failed to update cover photo. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }

  Future<ProfileStudentModel> updateStudentAbout(String about) async {
    const String mutation = '''
    mutation UpdateStudentAbout(\$about: String!) {
      updateStudentAbout(about: \$about) {
        id
        roll
        section
        name
        email
        about
        department
        semester
        cgpa
        profile_picture
        user_id {
          id
          name
          email
          profile_picture
          cover_picture
        }
      }
    }
    ''';

    final variables = {
      'about': about,
    };

    try {
      final response = await dioClient
          .getDio(AppConfig.graphqlServer)
          .post('/', data: {
        'query': mutation,
        'variables': variables,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['errors'] != null) {
          throw Exception('GraphQL returned errors: ${data['errors']}');
        }
        if (data['data'] != null && data['data']['updateStudentAbout'] != null) {
          return ProfileStudentModel.fromJson(data['data']['updateStudentAbout']);
        } else {
          throw Exception('Student data is missing');
        }
      } else {
        throw Exception('Failed to update student about. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }

  Future<ProfileStudentModel> updateStudentInfo({
    String? roll,
    String? section,
    String? department,
    String? semester,
    String? cgpa,
  }) async {
    const String mutation = '''
    mutation UpdateStudentInfo(\$studentInput: UpdateStudentInput!) {
      updateStudentInfo(studentInput: \$studentInput) {
        id
        roll
        section
        name
        email
        department
        semester
        cgpa
        user_id {
          id
          name
          email
          profile_picture
          cover_picture
        }
      }
    }
    ''';

    final variables = {
      'studentInput': {
        if (roll != null) 'roll': roll,
        if (section != null) 'section': section,
        if (department != null) 'department': department,
        if (semester != null) 'semester': semester,
        if (cgpa != null) 'cgpa': cgpa,
      },
    };

    try {
      final response = await dioClient
          .getDio(AppConfig.graphqlServer)
          .post('/', data: {
        'query': mutation,
        'variables': variables,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['errors'] != null) {
          throw Exception('GraphQL returned errors: ${data['errors']}');
        }
        if (data['data'] != null && data['data']['updateStudentInfo'] != null) {
          return ProfileStudentModel.fromJson(data['data']['updateStudentInfo']);
        } else {
          throw Exception('Student data is missing');
        }
      } else {
        throw Exception('Failed to update student info. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }
}