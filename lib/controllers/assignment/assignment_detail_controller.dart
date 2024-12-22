import 'package:classmate/models/assignment/assignment_detail_model.dart';
import 'package:classmate/services/assignment/assignment_detail_service.dart';
import 'package:flutter/material.dart';

enum AssignmentDetailState { idle, loading, success, error }

class AssignmentDetailController {
  final AssignmentDetailService _assignmentDetailService = AssignmentDetailService();

  // State management
  final ValueNotifier<AssignmentDetailState> stateNotifier =
  ValueNotifier<AssignmentDetailState>(AssignmentDetailState.idle);
  String? errorMessage; // To store error messages
  AssignmentDetailModel? assignmentDetail; // To store the fetched assignment details

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
  Future<void> checkAssignmentSubmission(String assignmentId) async {
    stateNotifier.value = AssignmentDetailState.loading;
    errorMessage = '';
    try {
      final hasSubmission = await _assignmentDetailService.checkAssignmentSubmission(assignmentId);
      if (hasSubmission) {
        stateNotifier.value = AssignmentDetailState.success;
      } else {
        errorMessage = 'No submission found.';
        stateNotifier.value = AssignmentDetailState.error;
      }
    } catch (e) {
      errorMessage = 'Error checking assignment submission: $e';
      stateNotifier.value = AssignmentDetailState.error;
    }
  }

  // Method to fetch assignment details
  Future<void> getAssignmentDetails(String assignmentId) async {
    stateNotifier.value = AssignmentDetailState.loading; // Set state to loading
    errorMessage = null;
    try {
      // Fetch assignment details from the service
      final details = await _assignmentDetailService.getAssignmentDetails(assignmentId);
      assignmentDetail = details; // Store the fetched details
      // print("came here");
      // print(assignmentDetail?.assignment?.description);
      // print(assignmentDetail?.submission?.teacherComments);
      stateNotifier.value = AssignmentDetailState.success; // Set state to success
    } catch (e) {
      errorMessage = 'Error fetching assignment details: $e';
      stateNotifier.value = AssignmentDetailState.error; // Set state to error
    }
  }


}
