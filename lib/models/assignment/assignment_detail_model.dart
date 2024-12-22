import 'package:classmate/models/assignment/assignment_model.dart';
import 'package:classmate/models/assignment/submission_model.dart';

class AssignmentDetailModel {
  final AssignmentModel? assignment; // The assignment details
  final SubmissionModel? submission; // The submission details

  const AssignmentDetailModel({
    this.assignment,
    this.submission,
  });
  // Factory method to create an AssignmentDetailModel from JSON
  factory AssignmentDetailModel.fromJson(Map<String, dynamic> json) {
    final assignmentJson = json['assignment'] as Map<String, dynamic>?;
    return AssignmentDetailModel(
      assignment: assignmentJson != null
          ? AssignmentModel.fromJson(assignmentJson)
          : null,
      submission: assignmentJson?['submission'] != null
          ? SubmissionModel.fromJson(assignmentJson?['submission'] as Map<String, dynamic>)
          : null,
    );
  }
}
