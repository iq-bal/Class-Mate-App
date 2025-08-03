import 'package:classmate/models/assignment_teacher/submission_detail_model.dart';
import 'package:classmate/models/assignment_teacher/evaluation_model.dart';
import 'package:classmate/services/assignment_teacher/assignment_teacher_services.dart';
import 'package:flutter/material.dart';

enum AssignmentTeacherState { idle, loading, success, error }

class AssignmentTeacherController {
  final AssignmentTeacherServices _assignmentTeacherServices = AssignmentTeacherServices();

  final ValueNotifier<AssignmentTeacherState> stateNotifier =
  ValueNotifier<AssignmentTeacherState>(AssignmentTeacherState.idle);

  String? errorMessage;
  SubmissionDetailModel? submissionDetails;

  EvaluationModel? evaluationDetail;

  Future<void> fetchAssignmentSubmissions(String assignmentId) async {
    stateNotifier.value = AssignmentTeacherState.loading;
    try {
      submissionDetails = await _assignmentTeacherServices.getAssignmentSubmissions(assignmentId);
      stateNotifier.value = AssignmentTeacherState.success;
    } catch (error) {
      errorMessage = error.toString();
      stateNotifier.value = AssignmentTeacherState.error;
    }
  }

  // Fetch a single submission by submissionId.
  Future<void> fetchSingleSubmission(String submissionId) async {
    stateNotifier.value = AssignmentTeacherState.loading;
    try {
      evaluationDetail = await _assignmentTeacherServices.getSingleSubmission(submissionId);
      stateNotifier.value = AssignmentTeacherState.success;
    } catch (error) {
      errorMessage = error.toString();
      stateNotifier.value = AssignmentTeacherState.error;
    }
  }

  Future<void> updateSubmission(String submissionId, Map<String, dynamic> submissionInput) async {
    stateNotifier.value = AssignmentTeacherState.loading;
    try {
      await _assignmentTeacherServices.updateSubmission(submissionId, submissionInput);
      await fetchSingleSubmission(submissionId);
      stateNotifier.value = AssignmentTeacherState.success;
    } catch (error) {
      errorMessage = error.toString();
      stateNotifier.value = AssignmentTeacherState.error;
    }
  }

}
