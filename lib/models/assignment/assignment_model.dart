import 'package:classmate/entity/assignment_entity.dart';

class AssignmentModel extends AssignmentEntity {
  const AssignmentModel({
    super.title,
    super.description,
  }) : super(
    id: null,
    courseId: null,
    deadline: null,
    createdAt: null,
  );

  // Factory method to create an AssignmentModel from JSON
  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    return AssignmentModel(
      title: json['title'] as String?,
      description: json['description'] as String?,
    );
  }
}
