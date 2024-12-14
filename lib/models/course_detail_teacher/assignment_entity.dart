import 'package:classmate/models/assignment_model.dart';
import 'package:classmate/models/submission_model.dart';

class AssignmentEntity extends AssignmentModel {
  final List<SubmissionModel> submissions;

  AssignmentEntity({
    required String id,
    required String title,
    required String description,
    required String deadline,
    required String createdAt,
    required String courseId,
    required this.submissions,
  }) : super(
    id: id,
    title: title,
    description: description,
    deadline: deadline,
    createdAt: createdAt,
    courseId: courseId,
  );

  // Factory constructor to create an AssignmentEntity object from JSON
  factory AssignmentEntity.fromJson(Map<String, dynamic> json) {

    // Create AssignmentModel part using fromJson from parent class
    final assignmentModel = AssignmentModel.fromJson(json);
    List<SubmissionModel> submissionsList = [];
    if (json['submissions'] != null) {
      submissionsList = List<SubmissionModel>.from(
        json['submissions'].map((submission) => SubmissionModel.fromJson(submission)),
      );
    }

    // Return an instance of AssignmentEntity with submissions and other properties
    return AssignmentEntity(
      id: assignmentModel.id ?? '',
      title: assignmentModel.title ?? '',
      description: assignmentModel.description ?? '',
      deadline: assignmentModel.deadline ?? '',
      createdAt: assignmentModel.createdAt ?? '',
      courseId: assignmentModel.courseId ?? '',
      submissions: submissionsList,
    );
  }
}
