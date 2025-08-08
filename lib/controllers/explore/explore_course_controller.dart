import 'package:classmate/models/explore/course_card_model.dart';
import 'package:classmate/models/explore/explore_course_model.dart';
import 'package:classmate/models/explore/popular_card_model.dart';
import 'package:classmate/services/explore/explore_course_service.dart';
import 'package:flutter/material.dart';

enum ExploreCourseState { idle, loading, success, error }

class ExploreCourseController {
  final ExploreCourseService _exploreCourseService = ExploreCourseService();
  final ValueNotifier<ExploreCourseState> stateNotifier = ValueNotifier<ExploreCourseState>(ExploreCourseState.idle);
  String? errorMessage;
  List<ExploreCourseModel>? courses;
  List<CourseCardModel>? allCourses;
  List<PopularCardModel>? popularCourses; // Add this


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

  Future<void> loadAllCourses() async {
    stateNotifier.value = ExploreCourseState.loading;
    errorMessage = '';
    try {
      allCourses = await _exploreCourseService.getCourses();
      stateNotifier.value = ExploreCourseState.success;
    } catch (e) {
      errorMessage = 'Failed to load courses: $e';
      stateNotifier.value = ExploreCourseState.error;
    }
  }

  // Load popular courses
  Future<void> loadPopularCourses() async {
    stateNotifier.value = ExploreCourseState.loading;
    errorMessage = '';
    try {
      popularCourses = await _exploreCourseService.getPopularCourses();
      stateNotifier.value = ExploreCourseState.success;
    } catch (e) {
      errorMessage = 'Failed to load popular courses: $e';
      stateNotifier.value = ExploreCourseState.error;
    }
  }

  // Refresh all course data
  Future<void> refreshData() async {
    stateNotifier.value = ExploreCourseState.loading;
    errorMessage = '';
    try {
      // Load both all courses and popular courses in parallel
      await Future.wait([
        _exploreCourseService.getCourses().then((courses) => allCourses = courses),
        _exploreCourseService.getPopularCourses().then((popular) => popularCourses = popular),
      ]);
      stateNotifier.value = ExploreCourseState.success;
    } catch (e) {
      errorMessage = 'Failed to refresh data: $e';
      stateNotifier.value = ExploreCourseState.error;
    }
  }

}
