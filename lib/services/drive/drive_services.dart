import 'package:dio/dio.dart';
import 'package:classmate/config/app_config.dart';
import 'package:classmate/core/dio_client.dart';
import 'package:classmate/models/drive/drive_model.dart';
import 'package:classmate/entity/drive_file_entity.dart';
import 'dart:io';
import 'dart:convert';

class DriveServices {
  final DioClient dioClient = DioClient();

  // Get drive files by course ID
  Future<DriveModel> getDriveFilesByCourse(String courseId) async {
    const String query = '''
    query GetDriveFilesByCourse(\$courseId: ID!) {
      driveFiles(course_id: \$courseId) {
        id
        file_name
        file_url
        file_size
        file_type
        description
        uploaded_at
        teacher {
          id
          name
          profile_picture
        }
        course {
          id
          title
          course_code
        }
      }
    }
    ''';

    try {
      final variables = {
        'courseId': courseId,
      };

      final response = await dioClient
          .getDio(AppConfig.graphqlServer)
          .post(
        '/',
        data: {'query': query, 'variables': variables},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['errors'] != null) {
          throw Exception('GraphQL returned errors: ${data['errors']}');
        }
        if (data['data'] != null) {
          return DriveModel.fromJson(data);
        } else {
          throw Exception('Response data is null');
        }
      } else {
        throw Exception('Failed to fetch drive files. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }

  // Upload drive file
  Future<UploadDriveFileModel> uploadDriveFile({
    required String courseId,
    required File file,
    String? description,
  }) async {
    const String mutation = '''
    mutation UploadDriveFile(\$input: UploadDriveFileInput!) {
      uploadDriveFile(input: \$input) {
        id
        file_name
        file_url
        file_size
        file_type
        description
        uploaded_at
        teacher {
          id
          name
          profile_picture
        }
        course {
          id
          title
          course_code
        }
      }
    }
    ''';

    try {
      // Create FormData for file upload
      final escapedDescription = (description ?? '').replaceAll('"', '\\"').replaceAll('\n', '\\n');
      final escapedMutation = mutation.replaceAll('\n', ' ').replaceAll('  ', ' ');
      
      final operations = {
        "query": escapedMutation,
        "variables": {
          "input": {
            "course_id": courseId,
            "file": null,
            "description": escapedDescription
          }
        }
      };
      
      FormData formData = FormData.fromMap({
        'operations': jsonEncode(operations),
        'map': '{"0": ["variables.input.file"]}',
        '0': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      });

      final response = await dioClient
          .getDio(AppConfig.graphqlServer)
          .post(
        '/',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['errors'] != null) {
          throw Exception('GraphQL returned errors: ${data['errors']}');
        }
        if (data['data'] != null) {
          return UploadDriveFileModel.fromJson(data);
        } else {
          throw Exception('Response data is null');
        }
      } else {
        throw Exception('Failed to upload file. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }

  // Delete drive file
  Future<bool> deleteDriveFile(String fileId) async {
    const String mutation = '''
    mutation DeleteDriveFile(\$id: ID!) {
      deleteDriveFile(id: \$id)
    }
    ''';

    try {
      final variables = {
        'id': fileId,
      };

      final response = await dioClient
          .getDio(AppConfig.graphqlServer)
          .post(
        '/',
        data: {'query': mutation, 'variables': variables},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['errors'] != null) {
          throw Exception('GraphQL returned errors: ${data['errors']}');
        }
        return data['data']['deleteDriveFile'] == true;
      } else {
        throw Exception('Failed to delete file. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }

  // Rename drive file
  Future<DriveFileEntity> renameDriveFile(String fileId, String newFileName) async {
    const String mutation = '''
    mutation RenameDriveFile(\$id: ID!, \$input: RenameDriveFileInput!) {
      renameDriveFile(id: \$id, input: \$input) {
        id
        file_name
        file_url
        file_size
        file_type
        description
        uploaded_at
        teacher {
          id
          name
          profile_picture
        }
        course {
          id
          title
          course_code
        }
      }
    }
    ''';

    try {
      final variables = {
        'id': fileId,
        'input': {
          'file_name': newFileName,
        },
      };

      final response = await dioClient
          .getDio(AppConfig.graphqlServer)
          .post(
        '/',
        data: {'query': mutation, 'variables': variables},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['errors'] != null) {
          throw Exception('GraphQL returned errors: ${data['errors']}');
        }
        if (data['data'] != null && data['data']['renameDriveFile'] != null) {
          return DriveFileEntity.fromJson(data['data']['renameDriveFile']);
        } else {
          throw Exception('Response data is null');
        }
      } else {
        throw Exception('Failed to rename file. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }
}