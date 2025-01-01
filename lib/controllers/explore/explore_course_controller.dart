import 'package:classmate/models/explore/explore_course_model.dart';
import 'package:classmate/services/explore/explore_course_service.dart';
import 'package:flutter/material.dart';

enum ExploreCourseState { idle, loading, success, error }

class ExploreCourseController {
  final ExploreCourseService _exploreCourseService = ExploreCourseService();
  final ValueNotifier<ExploreCourseState> stateNotifier = ValueNotifier<ExploreCourseState>(ExploreCourseState.idle);
  String? errorMessage;
  List<ExploreCourseModel>? courses;

  // Search for courses by name
  Future<void> searchCourses(String keyword) async {
    stateNotifier.value = ExploreCourseState.loading;
    errorMessage = '';
    try {
      courses = await _exploreCourseService.searchCourses(keyword);
      stateNotifier.value = ExploreCourseState.success;
    } catch (e) {
      errorMessage = 'Failed to search courses: $e';
      stateNotifier.value = ExploreCourseState.error;
    }
  }
}
