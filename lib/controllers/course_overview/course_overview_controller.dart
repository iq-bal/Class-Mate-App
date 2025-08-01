import 'package:classmate/models/course_overview/course_overview_model.dart';
import 'package:classmate/models/enrollment/enrollment_status_model.dart';
import 'package:classmate/services/course_overview/course_overview_service.dart';
import 'package:flutter/material.dart';

enum CourseOverviewState { idle, loading, success, error, enrolling, enrolled, checkingEnrollment }

class CourseOverviewController {
  final CourseOverviewService _courseOverviewService = CourseOverviewService();

  final ValueNotifier<CourseOverviewState> stateNotifier =
      ValueNotifier<CourseOverviewState>(CourseOverviewState.idle);

  String? errorMessage;
  CourseOverviewModel? courseOverview;
  EnrollmentStatusModel? enrollmentStatus;
  String enrollButtonText = 'Enroll';

  Future<void> getCourseOverview(String courseId) async {
    stateNotifier.value = CourseOverviewState.loading;
    try {
      courseOverview = await _courseOverviewService.getCourseOverview(courseId);
      await checkEnrollmentStatus(courseId);
      stateNotifier.value = CourseOverviewState.success;
    } catch (error) {
      errorMessage = error.toString();
      stateNotifier.value = CourseOverviewState.error;
    }
  }
  
  Future<void> checkEnrollmentStatus(String courseId) async {
    try {
      enrollmentStatus = await _courseOverviewService.getEnrollmentStatus(courseId);
      if (enrollmentStatus != null) {
        enrollButtonText = enrollmentStatus!.status;
      } else {
        enrollButtonText = 'Enroll';
      }
    } catch (error) {
      errorMessage = error.toString();
      // Don't change the state here, just log the error
      print('Error checking enrollment status: $error');
    }
  }
  
  Future<void> enrollInCourse(String courseId) async {
    stateNotifier.value = CourseOverviewState.enrolling;
    try {
      final result = await _courseOverviewService.enrollInCourse(courseId);
      if (result != null && result['id'] != null) {
        // Update enrollment status after successful enrollment
        await checkEnrollmentStatus(courseId);
        stateNotifier.value = CourseOverviewState.enrolled;
      } else {
        errorMessage = 'Failed to enroll in course';
        stateNotifier.value = CourseOverviewState.error;
      }
    } catch (error) {
      errorMessage = error.toString();
      stateNotifier.value = CourseOverviewState.error;
    }
  }
}