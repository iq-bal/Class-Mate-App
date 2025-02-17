class SubmissionEntity {
  final String? id;
  final String? assignmentId;
  final String? studentId;
  final String? fileUrl;
  final double? plagiarismScore;
  final double? aiGenerated;
  final String? teacherComments;
  final double? grade; // Change grade type to double
  final String? submittedAt; // Change to String
  final String? evaluatedAt; // Change to String

  const SubmissionEntity({
    this.id,
    this.assignmentId,
    this.studentId,
    this.fileUrl,
    this.plagiarismScore,
    this.aiGenerated,
    this.teacherComments,
    this.grade,
    this.submittedAt,
    this.evaluatedAt,
  });

  // Factory method to create a SubmissionEntity from JSON
  factory SubmissionEntity.fromJson(Map<String, dynamic> json) {
    return SubmissionEntity(
      id: json['id'] as String?,
      assignmentId: json['assignment_id'] as String?,
      studentId: json['student_id'] as String?,
      fileUrl: json['file_url'] as String?,
      plagiarismScore: (json['plagiarism_score'] as num?)?.toDouble(),
      aiGenerated: (json['ai_generated'] as num?)?.toDouble(),
      teacherComments: json['teacher_comments'] as String?,
      grade: (json['grade'] as num?)?.toDouble(), // Convert grade to double
      submittedAt: json['submitted_at'] as String?, // Directly assign as String
      evaluatedAt: json['evaluated_at'] as String?, // Directly assign as String
    );
  }
}
