import 'package:classmate/models/submission_entity.dart';

class EvaluationModel extends SubmissionEntity {
  EvaluationModel({
    required super.id,
    required super.fileUrl,
    required super.plagiarismScore,
    required super.teacherComment,
    required String? grade, // Mark grade as nullable
    required super.submittedAt,
  }) : super(
    assignmentId: null,
    studentId: null,
    grade: grade ?? 'Not graded yet', // Provide a default value for null grade
  );

  // Factory method to create an EvaluationModel from JSON
  factory EvaluationModel.fromJson(Map<String, dynamic> json) {
    return EvaluationModel(
      id: json['_id'] as String, // Cast to String
      fileUrl: json['file_url'] as String, // Cast to String
      plagiarismScore: (json['plagiarism_score'] as num).toDouble(), // Cast to double
      teacherComment: json['teacher_comments'] as String? ?? '', // Handle nullable teacherComment
      grade: json['grade'] as String?, // Allow nullable grade
      submittedAt: DateTime.parse(json['submitted_at'] as String), // Parse DateTime
    );
  }
}
