import 'package:classmate/entity/submission_entity.dart';
import 'package:classmate/models/assignment/student_model.dart';

class SubmissionModel extends SubmissionEntity {
  final StudentModel? student;

  SubmissionModel({
    super.id,
    super.fileUrl,
    super.plagiarismScore,
    super.grade,
    super.aiGenerated,
    super.teacherComments,
    super.submittedAt,
    super.evaluatedAt,
    this.student,
  }) : super(
    assignmentId: null,
    studentId: null,
  );

  // Factory method to create a SubmissionModel from JSON
  factory SubmissionModel.fromJson(Map<String, dynamic> json) {
    return SubmissionModel(
      id: json['id'] as String?,
      fileUrl: json['file_url'] as String?,
      plagiarismScore: (json['plagiarism_score'] as num?)?.toDouble(),
      grade: (json['grade'] as num?)?.toDouble(),
      aiGenerated: (json['ai_generated'] as num?)?.toDouble(),
      teacherComments: json['teacher_comments'] as String?,
      submittedAt: json['submitted_at'] as String?,
      evaluatedAt: json['evaluated_at'] as String?,
      student: json['student'] != null ? StudentModel.fromJson(json['student'] as Map<String, dynamic>) : null,
    );
  }
}
