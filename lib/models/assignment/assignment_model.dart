import 'package:classmate/entity/assignment_entity.dart';

class AssignmentModel extends AssignmentEntity {
  const AssignmentModel({
    super.id,
    super.title,
    super.description,
    super.deadline,
    super.createdAt,
    super.submissionCount,
  }) : super(
    courseId: null,
  );

  // Factory method to create an AssignmentModel from JSON
  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseCreatedAt(dynamic createdAtValue) {
      if (createdAtValue == null) return null;
      
      try {
        // Check if it's a timestamp (numeric string)
        if (createdAtValue is String && RegExp(r'^\d+$').hasMatch(createdAtValue)) {
          final timestamp = int.parse(createdAtValue);
          return DateTime.fromMillisecondsSinceEpoch(timestamp);
        }
        // Otherwise try to parse as ISO date string
        return DateTime.parse(createdAtValue.toString());
      } catch (e) {
        return null;
      }
    }
    
    return AssignmentModel(
      id: json['id'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline'] as String) : null,
      createdAt: parseCreatedAt(json['created_at']),
      submissionCount: json['submissionCount'] as int?,
    );
  }
}
