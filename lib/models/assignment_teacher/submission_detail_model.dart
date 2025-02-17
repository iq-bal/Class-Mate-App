import 'assignment_submission_model.dart';

class SubmissionDetailModel {
  final List<AssignmentSubmissionModel> submissionsByAssignment;

  const SubmissionDetailModel({
    required this.submissionsByAssignment,
  });

  factory SubmissionDetailModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final submissionsList = data['submissionsByAssignment'] as List<dynamic>;
    return SubmissionDetailModel(
      submissionsByAssignment: submissionsList
          .map((e) => AssignmentSubmissionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
