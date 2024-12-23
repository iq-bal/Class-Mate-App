import 'package:classmate/entity/assignment_entity.dart';

class AssignmentModel extends AssignmentEntity {
  const AssignmentModel({
    super.id,
    super.title,
    super.description,
  }) : super(
    courseId: null,
    deadline: null,
    createdAt: null,
  );

  // Factory method to create an AssignmentModel from JSON
  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    return AssignmentModel(
      id: json['id'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
    );
  }
}
