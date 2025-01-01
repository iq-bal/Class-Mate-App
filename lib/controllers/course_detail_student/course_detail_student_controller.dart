import 'package:classmate/services/course_detail_student/course_detail_student_service.dart';
import 'package:flutter/material.dart';

import '../../models/course_detail_student/course_detail_student_model.dart';

enum CourseDetailStudentState { idle, loading, success, error }

class CourseDetailStudentController {
  final CourseDetailStudentService _courseDetailStudentService = CourseDetailStudentService();

  // State management
  final ValueNotifier<CourseDetailStudentState> stateNotifier =
  ValueNotifier<CourseDetailStudentState>(CourseDetailStudentState.idle);
  String? errorMessage;
  CourseDetailStudentModel? courseDetail;

  Future<void> enrollInCourse(String courseId) async {
    stateNotifier.value = CourseDetailStudentState.loading;
    try {
      await _courseDetailStudentService.enroll(courseId);
      stateNotifier.value = CourseDetailStudentState.success;
    } catch (error) {
      errorMessage = error.toString();
      stateNotifier.value = CourseDetailStudentState.error;
    }
  }

  Future<void> getCourseDetailsAndSyllabuses(String courseId) async {
    stateNotifier.value = CourseDetailStudentState.loading;
    try {
      courseDetail = await _courseDetailStudentService.getCourseDetailsAndSyllabuses(courseId);
      if (courseDetail != null) {
        stateNotifier.value = CourseDetailStudentState.success;
      } else {
        stateNotifier.value = CourseDetailStudentState.error;
        errorMessage = "Failed to fetch course details";
      }
    } catch (error) {
      errorMessage = error.toString();
      stateNotifier.value = CourseDetailStudentState.error;
    }
  }

}