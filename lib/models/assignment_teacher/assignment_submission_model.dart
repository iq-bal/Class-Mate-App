import 'package:classmate/entity/assignment_entity.dart';
import 'package:classmate/entity/student_entity.dart';
import 'submission_model.dart'; // This is your extended submission model

class AssignmentSubmissionModel {
  final SubmissionModel submission;
  final StudentEntity student;
  final AssignmentEntity assignment;

  const AssignmentSubmissionModel({
    required this.submission,
    required this.student,
    required this.assignment,
  });
  factory AssignmentSubmissionModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> submissionJson = Map<String, dynamic>.from(json);
    if (submissionJson['assignment_id'] is Map) {
      submissionJson['assignment_id'] =
      (submissionJson['assignment_id'] as Map<String, dynamic>)['id'];
    }
    if ((submissionJson['student_id'] == null || submissionJson['student_id'] == '') &&
        submissionJson['student'] is Map) {
      submissionJson['student_id'] =
      (submissionJson['student'] as Map<String, dynamic>)['id'];
    }
    final submission = SubmissionModel.fromJson(submissionJson);
    final student = StudentEntity.fromJson(json['student'] as Map<String, dynamic>);
    final assignment = AssignmentEntity.fromJson(json['assignment_id'] as Map<String, dynamic>);
    return AssignmentSubmissionModel(
      submission: submission,
      student: student,
      assignment: assignment,
    );
  }
}
