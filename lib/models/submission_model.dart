class SubmissionModel {
  final String? id;
  final String? assignmentId;
  final String? studentId;
  final String? fileUrl;
  final String? plagiarismScore;
  final String? teacherComment;
  final String? grade;
  final String? submittedAt;

  SubmissionModel({
    this.id,
    this.assignmentId,
    this.studentId,
    this.fileUrl,
    this.plagiarismScore,
    this.teacherComment, // Correct name
    this.grade,
    this.submittedAt,
  });

  // Factory method to create an instance from JSON
  factory SubmissionModel.fromJson(Map<String, dynamic> json) {
    return SubmissionModel(
      id: json['id']?.toString(),
      assignmentId: json['assignment_id']?.toString(),
      studentId: json['student_id']?.toString(),
      fileUrl: json['file_url']?.toString(),
      plagiarismScore: json['plagiarism_score']?.toString(),
      teacherComment: json['teacher_comments']?.toString(), // Correct key
      grade: json['grade']?.toString(),
      submittedAt: json['submitted_at']?.toString(),
    );
  }

  // Convert the object to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (assignmentId != null) 'assignment_id': assignmentId,
      if (studentId != null) 'student_id': studentId,
      if (fileUrl != null) 'file_url': fileUrl,
      if (plagiarismScore != null) 'plagiarism_score': plagiarismScore,
      if (teacherComment != null) 'teacher_comments': teacherComment, // Correct key
      if (grade != null) 'grade': grade,
      if (submittedAt != null) 'submitted_at': submittedAt,
    };
  }
}
