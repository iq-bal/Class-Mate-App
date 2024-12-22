class SubmissionEntity {
  final String? id;
  final String? assignmentId;
  final String? studentId;
  final String? fileUrl;
  final double? plagiarismScore;
  final double? aiGenerated;
  final String? teacherComments;
  final String? grade;
  final DateTime? submittedAt;
  final DateTime? evaluatedAt;

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
      grade: json['grade'] as String?,
      submittedAt: json['submitted_at'] != null ? DateTime.parse(json['submitted_at'] as String) : null,
      evaluatedAt: json['evaluated_at'] != null ? DateTime.parse(json['evaluated_at'] as String) : null,
    );
  }
}
