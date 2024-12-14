import 'package:classmate/models/submission_model.dart';

class AssignmentModel {
  final String? id;
  final String? courseId;
  final String? title;
  final String? description;
  final String? deadline;
  final String? createdAt;

  AssignmentModel({
    this.id,
    this.courseId,
    this.title,
    this.description,
    this.deadline,
    this.createdAt,
  });

  // Factory constructor to create an AssignmentModel object from a JSON map
  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    return AssignmentModel(
      id: json['id']?.toString(),
      courseId: json['course_id']?.toString(),
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      deadline: json['deadline']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }

  // Convert the AssignmentModel object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (courseId != null) 'course_id': courseId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (deadline != null) 'deadline': deadline,
      if (createdAt != null) 'created_at': createdAt,
    };
  }
}
