import 'package:classmate/models/assignment/evaluation_model.dart';
import 'package:classmate/services/assignment/assignment_detail_service.dart';
import 'package:flutter/material.dart';

enum AssignmentDetailState { idle, loading, success, error }

class AssignmentDetailController {
  final AssignmentDetailService _assignmentDetailService = AssignmentDetailService();

  // State management
  final ValueNotifier<AssignmentDetailState> stateNotifier =
  ValueNotifier<AssignmentDetailState>(AssignmentDetailState.idle);
  String? errorMessage; // To store error messages
  EvaluationModel? evaluationModel; // To store the fetched evaluation data


  // Method to submit an assignment
  Future<void> submitAssignment(String assignmentId, String filePath) async {
    stateNotifier.value = AssignmentDetailState.loading;
    errorMessage = '';
    try {
      await _assignmentDetailService.submitAssignmentWithFile(
        assignmentId,
        filePath
      );
      stateNotifier.value = AssignmentDetailState.success;
    } catch (e) {
      errorMessage = 'Failed to submit assignment: $e';
      stateNotifier.value = AssignmentDetailState.error; // Set error state
    }
  }

  // Method to check assignment submission
  Future<void> checkAssignmentSubmission(String assignmentId) async {
    stateNotifier.value = AssignmentDetailState.loading;
    errorMessage = '';
    try {
      final result = await _assignmentDetailService.checkAssignmentSubmission(assignmentId);
      if (result != null) {
        evaluationModel = result;
        stateNotifier.value = AssignmentDetailState.success;
      } else {
        errorMessage = 'No submission found.';
        stateNotifier.value = AssignmentDetailState.error;
      }
    } catch (e) {
      errorMessage = 'Error fetching assignment submission: $e';
      stateNotifier.value = AssignmentDetailState.error;
    }
  }

}
