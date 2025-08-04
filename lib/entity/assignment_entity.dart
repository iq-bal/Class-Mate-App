class AssignmentEntity {
  final String? id;
  final String? courseId;
  final String? title;
  final String? description;
  final DateTime? deadline;
  final DateTime? createdAt;
  final int? submissionCount;

  const AssignmentEntity({
    this.id,
    this.courseId,
    this.title,
    this.description,
    this.deadline,
    this.createdAt,
    this.submissionCount,
  });

  // Factory method to create an AssignmentEntity from JSON
  factory AssignmentEntity.fromJson(Map<String, dynamic> json) {
    return AssignmentEntity(
      id: json['id'] as String?,
      courseId: json['course_id'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline'] as String) : null,
      createdAt: json['created_at'] != null ? _parseDateTime(json['created_at']) : null,
      submissionCount: json['submissionCount'] as int?,
    );
  }

  // Helper method to parse DateTime from various formats
  static DateTime? _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return null;
    
    try {
      // If it's a string that looks like a Unix timestamp
      if (dateValue is String && RegExp(r'^\d+$').hasMatch(dateValue)) {
        final timestamp = int.parse(dateValue);
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
      // If it's an integer timestamp
      else if (dateValue is int) {
        return DateTime.fromMillisecondsSinceEpoch(dateValue);
      }
      // Otherwise try to parse as ISO date string
      else if (dateValue is String) {
        return DateTime.parse(dateValue);
      }
    } catch (e) {
      // Return null if parsing fails
      return null;
    }
    return null;
  }
}
