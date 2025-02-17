import 'package:classmate/models/assignment_teacher/submission_detail_model.dart';
import 'package:classmate/models/assignment_teacher/evaluation_model.dart';
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

  // Field for single submission (evaluation) detail.
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

  // Fetch a single submission by assignmentId and studentId.
  Future<void> fetchSingleSubmission(String assignmentId, String studentId) async {
    stateNotifier.value = AssignmentTeacherState.loading;
    try {
      evaluationDetail = await _assignmentTeacherServices.getSingleSubmission(assignmentId, studentId);

      // Print evaluationDetail to the console.
      printEvaluationDetail(evaluationDetail);

      stateNotifier.value = AssignmentTeacherState.success;
    } catch (error) {
      errorMessage = error.toString();
      stateNotifier.value = AssignmentTeacherState.error;
    }
  }

  // Helper method to print the evaluation detail to console.
  void printEvaluationDetail(EvaluationModel? eval) {
    if (eval == null) {
      print("No evaluation detail available.");
      return;
    }
    print("----- EVALUATION DETAIL -----");
    print("Submission ID: ${eval.submission.id}");
    print("Assignment ID (from submission): ${eval.submission.assignmentId}");
    print("Student ID (from submission): ${eval.submission.studentId}");
    print("File URL: ${eval.submission.fileUrl}");
    print("Plagiarism Score: ${eval.submission.plagiarismScore}");
    print("AI Generated: ${eval.submission.aiGenerated}");
    print("Teacher Comments: ${eval.submission.teacherComments}");
    print("Grade: ${eval.submission.grade}");
    print("Submitted At: ${eval.submission.submittedAt}");
    print("Evaluated At: ${eval.submission.evaluatedAt}");

    print("----- Student -----");
    print("Student ID: ${eval.student.id}");
    print("Name: ${eval.student.name}");
    print("Email: ${eval.student.email}");
    print("Roll: ${eval.student.roll}");
    print("Section: ${eval.student.section}");
    print("Profile Picture: ${eval.student.profilePicture}");

    print("----- Assignment -----");
    print("Assignment ID: ${eval.assignment.id}");
    print("Title: ${eval.assignment.title}");
    print("Description: ${eval.assignment.description}");
    print("Deadline: ${eval.assignment.deadline}");

    print("----- Teacher -----");
    print("Teacher ID: ${eval.teacher.id}");
    print("Teacher Name: ${eval.teacher.name}");
    print("Teacher Profile Picture: ${eval.teacher.profilePicture}");
    print("----- END EVALUATION DETAIL -----");
  }
}
