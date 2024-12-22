class AssignmentEntity {
  final String? id;
  final String? courseId;
  final String? title;
  final String? description;
  final DateTime? deadline;
  final DateTime? createdAt;

  const AssignmentEntity({
    this.id,
    this.courseId,
    this.title,
    this.description,
    this.deadline,
    this.createdAt,
  });

  // Factory method to create an AssignmentEntity from JSON
  factory AssignmentEntity.fromJson(Map<String, dynamic> json) {
    return AssignmentEntity(
      id: json['id'] as String?,
      courseId: json['course_id'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline'] as String) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
    );
  }
}
