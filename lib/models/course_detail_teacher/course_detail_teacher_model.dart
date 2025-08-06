import 'package:classmate/models/assignment_model.dart';
import 'package:classmate/models/authentication/user_model.dart';
import 'package:classmate/models/course_detail_teacher/assignment_entity.dart';
import 'package:classmate/models/course_detail_teacher/class_test_entity.dart';
import 'package:classmate/models/create_course/schedule_model.dart';
import 'package:classmate/models/student_model.dart';

class CourseDetailTeacherModel {
  final String id;
  final String title;
  final String courseCode;
  final List<StudentModel> enrolledStudents;
  final List<ScheduleModel> schedules;
  final List<AssignmentEntity> assignments;
  final List<ClassTestEntity> classTests; 

  CourseDetailTeacherModel({
    required this.id,
    required this.title,
    required this.courseCode,
    required this.enrolledStudents,
    required this.assignments,
    required this.classTests,
    required this.schedules
  });

  factory CourseDetailTeacherModel.fromJson(Map<String, dynamic> json) {
    return CourseDetailTeacherModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      courseCode: json['course_code']?.toString() ?? '',
      enrolledStudents: (json['enrolled_students'] as List<dynamic>? ?? [])
          .map((student) => StudentModel.fromJson(student as Map<String, dynamic>))
          .toList(),
      assignments: (json['assignments'] as List<dynamic>? ?? [])
          .map((assignment) => AssignmentEntity.fromJson(assignment as Map<String, dynamic>))
          .toList(),
      classTests: (json['classTests'] as List<dynamic>? ?? [])
          .map((classTest) => ClassTestEntity.fromJson(classTest as Map<String, dynamic>))
          .toList(),
      schedules: (json['schedules'] as List<dynamic>? ?? [])
          .map((schedule) => ScheduleModel.fromJson(schedule as Map<String, dynamic>))
          .toList()
    );
  }
}