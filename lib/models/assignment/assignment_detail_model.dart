import 'package:classmate/models/assignment/assignment_model.dart';
import 'package:classmate/models/assignment/submission_model.dart';
import 'package:classmate/models/assignment/course_model.dart';
import 'package:classmate/models/assignment/teacher_model.dart';

class AssignmentDetailModel {
  final AssignmentModel? assignment; // The assignment details
  final SubmissionModel? submission; // The submission details
  final CourseModel? course; // The course details
  final TeacherModel? teacher; // The teacher details

  const AssignmentDetailModel({
    this.assignment,
    this.submission,
    this.course,
    this.teacher,
  });
  // Factory method to create an AssignmentDetailModel from JSON
  factory AssignmentDetailModel.fromJson(Map<String, dynamic> json) {
    final assignmentJson = json['assignment'] as Map<String, dynamic>?;
    
    if (assignmentJson == null) {
      return const AssignmentDetailModel();
    }
    
    // Create a copy of assignmentJson without nested objects for AssignmentModel
    final assignmentData = Map<String, dynamic>.from(assignmentJson);
    assignmentData.remove('course');
    assignmentData.remove('teacher');
    assignmentData.remove('submission');
    
    return AssignmentDetailModel(
      assignment: AssignmentModel.fromJson(assignmentData),
      submission: assignmentJson['submission'] != null
          ? SubmissionModel.fromJson(assignmentJson['submission'] as Map<String, dynamic>)
          : null,
      course: assignmentJson['course'] != null
          ? CourseModel.fromJson(assignmentJson['course'] as Map<String, dynamic>)
          : null,
      teacher: assignmentJson['teacher'] != null
          ? TeacherModel.fromJson(assignmentJson['teacher'] as Map<String, dynamic>)
          : null,
    );
  }
}
