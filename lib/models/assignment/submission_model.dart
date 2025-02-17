import 'package:classmate/entity/submission_entity.dart';

class SubmissionModel extends SubmissionEntity {
  SubmissionModel({
    required super.plagiarismScore,
    required super.grade, // grade is now double?
    required super.aiGenerated,
    required super.teacherComments,
  }) : super(
    id: null,
    assignmentId: null,
    studentId: null,
    fileUrl: null,
    submittedAt: null,
    evaluatedAt: null,
  );

  // Factory method to create a SubmissionModel from JSON
  factory SubmissionModel.fromJson(Map<String, dynamic> json) {
    return SubmissionModel(
      plagiarismScore: (json['plagiarism_score'] as num?)?.toDouble(),
      grade: (json['grade'] as num?)?.toDouble(),  // Ensure grade is parsed as double
      aiGenerated: (json['ai_generated'] as num?)?.toDouble(),
      teacherComments: json['teacher_comments'] as String?,
    );
  }
}
