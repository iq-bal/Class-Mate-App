import 'package:classmate/models/assignment_model.dart';
import 'package:classmate/models/authentication/user_model.dart';
import 'package:classmate/models/schedule_model.dart';

class CourseDetailTeacherModel {
  final String title;
  final String courseCode;
  final List<UserModel> enrolledStudents;
  final List<AssignmentModel> assignments;
  final List<ScheduleModel> schedules;

  // Constructor for CourseDetailTeacherModel
  CourseDetailTeacherModel({
    required this.title,
    required this.courseCode,
    required this.enrolledStudents,
    required this.assignments,
    required this.schedules
  });

  // Factory constructor to create a CourseDetailTeacherModel object from a JSON map
  factory CourseDetailTeacherModel.fromJson(Map<String, dynamic> json) {
    return CourseDetailTeacherModel(
      title: json['title'],
      courseCode: json['course_code'],
      enrolledStudents: (json['enrolled_students'] as List)
          .map((student) => UserModel.fromJson(student))
          .toList(),
      assignments: (json['assignments'] as List)
          .map((assignment) => AssignmentModel.fromJson(assignment))
          .toList(),
      schedules: (json['schedule'] as List)
          .map((schedule)=>ScheduleModel.fromJson(schedule))
          .toList(),
    );
  }
}