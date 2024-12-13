import 'package:classmate/models/course_detail_teacher/course_detail_teacher_model.dart';
import 'package:classmate/services/course_detail_teacher/course_detail_teacher_service.dart';
import 'package:flutter/material.dart';

enum CourseDetailState { idle, loading, success, error }

class CourseDetailTeacherController {
  final CourseDetailTeacherService _courseDetailTeacherService = CourseDetailTeacherService();

  // State management
  final ValueNotifier<CourseDetailState> stateNotifier = ValueNotifier<CourseDetailState>(CourseDetailState.idle);
  String? errorMessage; // To store error messages
  CourseDetailTeacherModel? courseDetail; // Store course details


  Future<void> fetchCourseDetails(String courseId) async {
    stateNotifier.value = CourseDetailState.loading;
    errorMessage = '';
    try {
      courseDetail = await _courseDetailTeacherService.getCourseDetails(courseId);
      stateNotifier.value = CourseDetailState.success;
      print("yeyyyyyy");
    } catch (e) {
      errorMessage = 'Failed to load course details: $e';
      stateNotifier.value = CourseDetailState.error; // Set error state
    }finally{
      stateNotifier.value = CourseDetailState.success;
    }
  }
}
