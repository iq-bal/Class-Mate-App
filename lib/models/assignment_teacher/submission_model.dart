import 'package:classmate/entity/submission_entity.dart';

class SubmissionModel extends SubmissionEntity {
  SubmissionModel({
    super.id,
    super.assignmentId,
    super.studentId,
    super.fileUrl,
    super.plagiarismScore,
    super.aiGenerated,
    super.teacherComments,
    super.grade,  // Ensure grade is a double?
  }) : super(
    submittedAt: null,
    evaluatedAt: null,
  );

  factory SubmissionModel.fromJson(Map<String, dynamic> json) {
    // Adjust JSON: if assignment_id is a Map, extract its 'id'
    String? assignId;
    if (json['assignment_id'] is Map) {
      assignId = (json['assignment_id'] as Map<String, dynamic>)['id'] as String?;
    } else {
      assignId = json['assignment_id'] as String?;
    }
    // Similarly, ensure student_id is a string.
    String? studId = json['student_id'] as String?;

    return SubmissionModel(
      id: json['id'] as String?,
      assignmentId: assignId,
      studentId: studId,
      fileUrl: json['file_url'] as String?,
      plagiarismScore: (json['plagiarism_score'] as num?)?.toDouble(),
      aiGenerated: (json['ai_generated'] as num?)?.toDouble(),
      teacherComments: json['teacher_comments'] as String?,
      grade: (json['grade'] as num?)?.toDouble(),  // Ensure grade is parsed as double
    );
  }
}
