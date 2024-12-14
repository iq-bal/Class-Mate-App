import 'package:classmate/models/assignment_model.dart';
import 'package:classmate/models/authentication/user_model.dart';
import 'package:classmate/models/schedule_model.dart';
import 'package:classmate/models/student_model.dart';

class CourseDetailTeacherModel {
  final String title;
  final String courseCode;
  final List<StudentModel> enrolledStudents;
  final List<AssignmentModel> assignments;
  final ScheduleModel schedule;

  CourseDetailTeacherModel({
    required this.title,
    required this.courseCode,
    required this.enrolledStudents,
    required this.assignments,
    required this.schedule
  });

  factory CourseDetailTeacherModel.fromJson(Map<String, dynamic> json) {
    return CourseDetailTeacherModel(
      title: json['title'].toString(),
      courseCode: json['course_code'].toString(),
      enrolledStudents: (json['enrolled_students'] as List)
          .map((student) => StudentModel.fromJson(student))
          .toList(),
      assignments: (json['assignments'] as List)
          .map((assignment) => AssignmentModel.fromJson(assignment))
          .toList(),
      schedule: ScheduleModel.fromJson(json['schedule'])
    );
  }
}