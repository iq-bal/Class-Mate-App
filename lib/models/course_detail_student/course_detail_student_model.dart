import 'package:classmate/entity/course_entity.dart';
import 'package:classmate/entity/syllabus_entity.dart';
import 'package:classmate/entity/teacher_entity.dart';

class CourseDetailStudentModel extends CourseEntity {
  final SyllabusEntity syllabusEntity;
  final TeacherEntity teacherEntity;
  final String? enrollmentStatus;  // New status field


  // Constructor
  const CourseDetailStudentModel({
    super.id,
    super.title,
    super.description,
    super.courseCode,
    required this.syllabusEntity,
    required this.teacherEntity,
    this.enrollmentStatus
  });

  // Factory method to create a CourseDetailStudentModel from JSON
  factory CourseDetailStudentModel.fromJson(Map<String, dynamic> json) {
    return CourseDetailStudentModel(
      id: json['id'] as String?,
      title: json['title'] as String?,
      courseCode: json['course_code'] as String?,
      description: json['description'] as String?,
      syllabusEntity: SyllabusEntity.fromJson(json['syllabus'] as Map<String, dynamic>),
      teacherEntity: TeacherEntity.fromJson(json['teacher'] as Map<String, dynamic>),
      enrollmentStatus: json['enrollment'] != null ? json['enrollment']['status'] as String? : null,  // Access the 'status' inside 'enrollment'
    );
  }
}
