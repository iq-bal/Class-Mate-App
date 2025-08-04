import 'package:classmate/entity/drive_file_entity.dart';

class DriveModel {
  final List<DriveFileEntity> files;
  final String? courseId;
  final String? courseTitle;
  final String? courseCode;

  const DriveModel({
    required this.files,
    this.courseId,
    this.courseTitle,
    this.courseCode,
  });

  factory DriveModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final driveFilesJson = data['driveFiles'] as List<dynamic>;
    
    final files = driveFilesJson
        .map((fileJson) => DriveFileEntity.fromJson(fileJson as Map<String, dynamic>))
        .toList();

    return DriveModel(
      files: files,
      courseId: files.isNotEmpty ? files.first.course?.id : null,
      courseTitle: files.isNotEmpty ? files.first.course?.title : null,
      courseCode: files.isNotEmpty ? files.first.course?.courseCode : null,
    );
  }
}

class UploadDriveFileModel {
  final DriveFileEntity file;

  const UploadDriveFileModel({
    required this.file,
  });

  factory UploadDriveFileModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final uploadDriveFileJson = data['uploadDriveFile'] as Map<String, dynamic>;
    
    return UploadDriveFileModel(
      file: DriveFileEntity.fromJson(uploadDriveFileJson),
    );
  }
}