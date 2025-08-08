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
    final submissionJson = data['submission'] as Map<String, dynamic>;

    // Create a copy of the submission JSON for adjustments.
    final Map<String, dynamic> adjustedJson = Map<String, dynamic>.from(submissionJson);

    // Convert numeric timestamps (epoch ms) to ISO8601 strings.
    if (adjustedJson['submitted_at'] is int) {
      final epoch = adjustedJson['submitted_at'] as int;
      adjustedJson['submitted_at'] = DateTime.fromMillisecondsSinceEpoch(epoch).toIso8601String();
    } else if (adjustedJson['submitted_at'] is String && RegExp(r'^\d+$').hasMatch(adjustedJson['submitted_at'])) {
      final epoch = int.parse(adjustedJson['submitted_at']);
      adjustedJson['submitted_at'] = DateTime.fromMillisecondsSinceEpoch(epoch).toIso8601String();
    }
    
    if (adjustedJson['evaluated_at'] is int) {
      final epoch = adjustedJson['evaluated_at'] as int;
      adjustedJson['evaluated_at'] = DateTime.fromMillisecondsSinceEpoch(epoch).toIso8601String();
    } else if (adjustedJson['evaluated_at'] is String && RegExp(r'^\d+$').hasMatch(adjustedJson['evaluated_at'])) {
      final epoch = int.parse(adjustedJson['evaluated_at']);
      adjustedJson['evaluated_at'] = DateTime.fromMillisecondsSinceEpoch(epoch).toIso8601String();
    }

    // Handle ai_generated field type conversion
    if (adjustedJson['ai_generated'] is int) {
      adjustedJson['ai_generated'] = (adjustedJson['ai_generated'] as int) == 1;
    }

    // Now, use your unmodified entity factories.
    final submission = SubmissionEntity.fromJson(adjustedJson);
    final student = StudentEntity.fromJson(submissionJson['student'] as Map<String, dynamic>);
    final assignment = AssignmentEntity.fromJson(submissionJson['assignment'] as Map<String, dynamic>);
    
    // Handle the new nested teacher structure
    final teacherData = submissionJson['assignment']['teacher'] as Map<String, dynamic>;
    final userData = teacherData['user'] as Map<String, dynamic>;
    
    // Merge teacher and user data for TeacherEntity
    final mergedTeacherData = {
      'id': teacherData['id'],
      'department': teacherData['department'],
      'designation': teacherData['designation'],
      'name': userData['name'],
      'profile_picture': userData['profile_picture'],
      'user_id': userData['id'],
    };
    
    final teacher = TeacherEntity.fromJson(mergedTeacherData);

    return EvaluationModel(
      submission: submission,
      student: student,
      assignment: assignment,
      teacher: teacher,
    );
  }
}
