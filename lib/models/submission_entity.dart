class SubmissionEntity {
  final String id;
  final String? assignmentId;
  final String? studentId;
  final String fileUrl;
  final double plagiarismScore;
  final double aiGenerated;
  final String teacherComment;
  final String grade;
  final DateTime submittedAt;

  const SubmissionEntity({
    required this.id,
    this.assignmentId,
    this.studentId,
    required this.fileUrl,
    required this.plagiarismScore,
    required this.aiGenerated,
    required this.teacherComment,
    required this.grade,
    required this.submittedAt,
  });
}
