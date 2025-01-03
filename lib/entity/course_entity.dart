import 'package:classmate/entity/schedule_entity.dart';

class CourseEntity {
  final String? id;
  final String? title;
  final String? courseCode;
  final String? description;
  final String? teacherId;
  final DateTime? createdAt;

  const CourseEntity({
    this.id,
    this.title,
    this.courseCode,
    this.description,
    this.teacherId,
    this.createdAt,
  });

  // Factory method to create a CourseEntity from JSON
  factory CourseEntity.fromJson(Map<String, dynamic> json) {
    return CourseEntity(
      id: json['id'] as String?,
      title: json['title'] as String?,
      courseCode: json['course_code'] as String?,
      description: json['description'] as String?,
      teacherId: json['teacher_id'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
    );
  }

  // Method to convert a CourseEntity to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'course_code': courseCode,
      'description': description,
      'teacher_id': teacherId,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}