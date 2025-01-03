import 'package:classmate/entity/attendance_entity.dart';
import 'package:classmate/entity/course_entity.dart';
import 'package:classmate/entity/schedule_entity.dart';
import 'package:classmate/entity/assignment_entity.dart';

class ClassDetailsStudentModel {
  final CourseEntity course;
  final ScheduleEntity? schedule;
  final List<AttendanceEntity> attendanceList;
  final List<AssignmentEntity> assignments;

  const ClassDetailsStudentModel({
    required this.course,
    this.schedule,
    required this.attendanceList,
    required this.assignments,
  });

  // Factory method to create ClassDetailsStudentModel from JSON
  factory ClassDetailsStudentModel.fromJson(Map<String, dynamic> json) {
    final courseData = json['course'];

    return ClassDetailsStudentModel(
      course: CourseEntity(
        id: courseData['id'] as String?,
        title: courseData['title'] as String?,
        courseCode: courseData['course_code'] as String?,
      ),
      schedule: courseData['schedule'] != null
          ? ScheduleEntity(
        day: courseData['schedule']['day'] as String,
        roomNo: courseData['schedule']['room_number'] as String,
        section: courseData['schedule']['section'] as String,
        startTime: courseData['schedule']['start_time'] as String,
        endTime: courseData['schedule']['end_time'] as String,
      )
          : null,
      attendanceList: (courseData['sessions'] as List<dynamic>)
          .map((session) {
        final attendance = session['attendance'];
        return AttendanceEntity(
          status: attendance?['status'] as String? ?? "absent", // Default to "absent" for null
        );
      })
          .toList(),
      assignments: (courseData['assignments'] as List<dynamic>)
          .map((assignment) => AssignmentEntity(
        title: assignment['title'] as String?,
        description: assignment['description'] as String?,
        deadline: assignment['deadline'] != null
            ? DateTime.parse(assignment['deadline'] as String)
            : null,
      ))
          .toList(),
    );
  }

}
