import 'package:classmate/models/assignment_teacher/submission_detail_model.dart';
import 'package:classmate/services/assignment_teacher/assignment_teacher_services.dart';
import 'package:flutter/material.dart';

enum AssignmentTeacherState { idle, loading, success, error }

class AssignmentTeacherController {
  final AssignmentTeacherServices _assignmentTeacherServices = AssignmentTeacherServices();

  // State management using ValueNotifier.
  final ValueNotifier<AssignmentTeacherState> stateNotifier =
  ValueNotifier<AssignmentTeacherState>(AssignmentTeacherState.idle);

  String? errorMessage;
  SubmissionDetailModel? submissionDetails;

  Future<void> fetchAssignmentSubmissions(String assignmentId) async {
    stateNotifier.value = AssignmentTeacherState.loading;
    try {
      submissionDetails = await _assignmentTeacherServices.getAssignmentSubmissions(assignmentId);
      stateNotifier.value = AssignmentTeacherState.success;

      // Print everything in submissionDetails.
      _printSubmissionDetails();

    } catch (error) {
      errorMessage = error.toString();
      stateNotifier.value = AssignmentTeacherState.error;
      print("Error: $errorMessage");
    }
  }

  void _printSubmissionDetails() {
    if (submissionDetails != null) {
      for (var submissionModel in submissionDetails!.submissionsByAssignment) {
        print("---------- Submission ----------");
        print("Submission ID: ${submissionModel.submission.id}");
        print("File URL: ${submissionModel.submission.fileUrl}");
        print("Plagiarism Score: ${submissionModel.submission.plagiarismScore}");
        print("AI Generated: ${submissionModel.submission.aiGenerated}");
        print("Teacher Comments: ${submissionModel.submission.teacherComments}");
        print("Grade: ${submissionModel.submission.grade}");
        print("Submitted At: ${submissionModel.submission.submittedAt}");
        print("Evaluated At: ${submissionModel.submission.evaluatedAt}");
        print("----- Student -----");
        print("Student ID: ${submissionModel.student.id}");
        print("Name: ${submissionModel.student.name}");
        print("Email: ${submissionModel.student.email}");
        print("Roll: ${submissionModel.student.roll}");
        print("Section: ${submissionModel.student.section}");
        print("Profile Picture: ${submissionModel.student.profilePicture}");
        print("----- Assignment -----");
        print("Assignment ID: ${submissionModel.assignment.id}");
        print("Title: ${submissionModel.assignment.title}");
        print("Description: ${submissionModel.assignment.description}");
        print("Deadline: ${submissionModel.assignment.deadline}");
      }
    } else {
      print("No submission details available.");
    }
  }
}
