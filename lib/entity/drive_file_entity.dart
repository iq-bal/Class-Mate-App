import 'package:classmate/entity/course_entity.dart';
import 'package:classmate/entity/teacher_entity.dart';

class DriveFileEntity {
  final String? id;
  final String? fileName;
  final String? fileUrl;
  final int? fileSize;
  final String? fileType;
  final String? description;
  final String? uploadedAt;
  final DriveTeacherEntity? teacher;
  final DriveCourseEntity? course;

  const DriveFileEntity({
    this.id,
    this.fileName,
    this.fileUrl,
    this.fileSize,
    this.fileType,
    this.description,
    this.uploadedAt,
    this.teacher,
    this.course,
  });

  factory DriveFileEntity.fromJson(Map<String, dynamic> json) {
    return DriveFileEntity(
      id: json['id'] as String?,
      fileName: json['file_name'] as String?,
      fileUrl: json['file_url'] as String?,
      fileSize: json['file_size'] as int?,
      fileType: json['file_type'] as String?,
      description: json['description'] as String?,
      uploadedAt: json['uploaded_at'] as String?,
      teacher: json['teacher'] != null 
          ? DriveTeacherEntity.fromJson(json['teacher'] as Map<String, dynamic>)
          : null,
      course: json['course'] != null 
          ? DriveCourseEntity.fromJson(json['course'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'file_name': fileName,
      'file_url': fileUrl,
      'file_size': fileSize,
      'file_type': fileType,
      'description': description,
      'uploaded_at': uploadedAt,
      'teacher': teacher?.toJson(),
      'course': course?.toJson(),
    };
  }
}

class DriveTeacherEntity {
  final String? id;
  final String? name;
  final String? profilePicture;

  const DriveTeacherEntity({
    this.id,
    this.name,
    this.profilePicture,
  });

  factory DriveTeacherEntity.fromJson(Map<String, dynamic> json) {
    return DriveTeacherEntity(
      id: json['id'] as String?,
      name: json['name'] as String?,
      profilePicture: json['profile_picture'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profile_picture': profilePicture,
    };
  }
}

class DriveCourseEntity {
  final String? id;
  final String? title;
  final String? courseCode;

  const DriveCourseEntity({
    this.id,
    this.title,
    this.courseCode,
  });

  factory DriveCourseEntity.fromJson(Map<String, dynamic> json) {
    return DriveCourseEntity(
      id: json['id'] as String?,
      title: json['title'] as String?,
      courseCode: json['course_code'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'course_code': courseCode,
    };
  }
}