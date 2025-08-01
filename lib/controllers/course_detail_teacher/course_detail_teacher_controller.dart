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


  Future<void> fetchCourseDetails(String courseId, String section, String day) async {
    stateNotifier.value = CourseDetailState.loading;
    errorMessage = '';
    try {
      courseDetail = await _courseDetailTeacherService.getCourseDetails(courseId,section,day);
      stateNotifier.value = CourseDetailState.success;
    } catch (e) {
      errorMessage = 'Failed to load course details: $e';
      stateNotifier.value = CourseDetailState.error; // Set error state
    }
  }

  Future<void> createAssignment(String courseId, String title,String description, String deadline)async {
    stateNotifier.value = CourseDetailState.loading;
    errorMessage = '';
    try{
      await _courseDetailTeacherService.createAssignment(courseId, title, description, deadline);
      stateNotifier.value = CourseDetailState.success;
    }catch (e){
      errorMessage = 'Failed to create assignment: $e';
      stateNotifier.value = CourseDetailState.error;
    }
  }

  Future<void> createClassTest(String courseId, String title, String description, String date, int duration, int totalMarks) async {
    stateNotifier.value = CourseDetailState.loading;
    errorMessage = '';
    try {
      await _courseDetailTeacherService.createClassTest(courseId, title, description, date, duration, totalMarks);
      stateNotifier.value = CourseDetailState.success;
    } catch (e) {
      errorMessage = 'Failed to create class test: $e';
      stateNotifier.value = CourseDetailState.error;
    }
  }

}
