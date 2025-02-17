import 'package:classmate/entity/submission_entity.dart';
import 'package:classmate/entity/student_entity.dart';
import 'package:classmate/entity/assignment_entity.dart';
import 'package:classmate/entity/teacher_entity.dart';

class EvaluationModel {
  final SubmissionEntity submission;
  final StudentEntity student;
  final AssignmentEntity assignment;
  final TeacherEntity teacher;

  const EvaluationModel({
    required this.submission,
    required this.student,
    required this.assignment,
    required this.teacher,
  });

  factory EvaluationModel.fromJson(Map<String, dynamic> json) {
    // Extract the top-level "data" object.
    final data = json['data'] as Map<String, dynamic>;
    // Extract the submission details.
    final submissionJson = data['getSubmissionByAssignmentAndStudent'] as Map<String, dynamic>;

    // Create a copy of the submission JSON for adjustments.
    final Map<String, dynamic> adjustedJson = Map<String, dynamic>.from(submissionJson);

    // If "assignment_id" is a Map, extract its 'id'
    if (adjustedJson['assignment_id'] is Map) {
      adjustedJson['assignment_id'] = (adjustedJson['assignment_id'] as Map<String, dynamic>)['id'];
    }

    // If "student_id" is a Map, extract its 'id'
    if (adjustedJson['student_id'] is Map) {
      adjustedJson['student_id'] = (adjustedJson['student_id'] as Map<String, dynamic>)['id'];
    }

    // Convert numeric timestamps (epoch ms) to ISO8601 strings.
    if (adjustedJson['submitted_at'] is int) {
      final epoch = adjustedJson['submitted_at'] as int;
      adjustedJson['submitted_at'] = DateTime.fromMillisecondsSinceEpoch(epoch).toIso8601String();
    }
    if (adjustedJson['evaluated_at'] is int) {
      final epoch = adjustedJson['evaluated_at'] as int;
      adjustedJson['evaluated_at'] = DateTime.fromMillisecondsSinceEpoch(epoch).toIso8601String();
    }

    // Now, use your unmodified entity factories.
    final submission = SubmissionEntity.fromJson(adjustedJson);
    final student = StudentEntity.fromJson(submissionJson['student'] as Map<String, dynamic>);

    final assignment = AssignmentEntity.fromJson(submissionJson['assignment_id'] as Map<String, dynamic>);

    final teacher = TeacherEntity.fromJson(
      (submissionJson['assignment_id'] as Map<String, dynamic>)['teacher'] as Map<String, dynamic>,
    );

    return EvaluationModel(
      submission: submission,
      student: student,
      assignment: assignment,
      teacher: teacher,
    );
  }
}
