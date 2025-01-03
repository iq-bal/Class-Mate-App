import 'package:classmate/models/class_details_student/class_details_student_model.dart';
import 'package:classmate/services/class_details_student/class_details_student_services.dart';
import 'package:flutter/material.dart';

enum CourseDetailStudentState { idle, loading, success, error }

class ClassDetailsStudentController {
  final ClassDetailsStudentServices _classDetailsStudentServices = ClassDetailsStudentServices();

  // State management
  final ValueNotifier<CourseDetailStudentState> stateNotifier =
  ValueNotifier<CourseDetailStudentState>(CourseDetailStudentState.idle);

  String? errorMessage;
  ClassDetailsStudentModel? classDetails;

  Future<void> fetchClassDetails(String courseId, String day, String teacherId) async {
    stateNotifier.value = CourseDetailStudentState.loading;
    try {
      classDetails = await _classDetailsStudentServices.getClassDetails(courseId, day, teacherId);
      stateNotifier.value = CourseDetailStudentState.success;
    } catch (error) {
      errorMessage = error.toString();
      stateNotifier.value = CourseDetailStudentState.error;
    }
  }

}
