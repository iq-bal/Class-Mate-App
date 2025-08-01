import 'package:classmate/models/course_overview/course_overview_model.dart';
import 'package:classmate/services/course_overview/course_overview_service.dart';
import 'package:flutter/material.dart';

enum CourseOverviewState { idle, loading, success, error }

class CourseOverviewController {
  final CourseOverviewService _courseOverviewService = CourseOverviewService();

  final ValueNotifier<CourseOverviewState> stateNotifier =
      ValueNotifier<CourseOverviewState>(CourseOverviewState.idle);

  String? errorMessage;
  CourseOverviewModel? courseOverview;

  Future<void> getCourseOverview(String courseId) async {
    stateNotifier.value = CourseOverviewState.loading;
    try {
      courseOverview = await _courseOverviewService.getCourseOverview(courseId);
      stateNotifier.value = CourseOverviewState.success;
    } catch (error) {
      errorMessage = error.toString();
      stateNotifier.value = CourseOverviewState.error;
    }
  }
}