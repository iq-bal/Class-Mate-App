import 'dart:io';
import 'package:classmate/models/create_course/create_course_model.dart';
import 'package:classmate/services/create_course/create_course_service.dart';
import 'package:flutter/material.dart';

enum CreateCourseState { idle, loading, success, error }

class CreateCourseController {
  final CreateCourseService _createCourseService = CreateCourseService();
  final ValueNotifier<CreateCourseState> stateNotifier = ValueNotifier(CreateCourseState.idle);

  String? errorMessage;
  CreateCourseModel? createdCourse;

  Future<void> createCourse({
    required String title,
    required String courseCode,
    required double credit,
    required String description,
    String? excerpt,
    String? imagePath,
  }) async {
    stateNotifier.value = CreateCourseState.loading;
    try {
      File? imageFile;
      if (imagePath != null) {
        imageFile = File(imagePath);
      }

      createdCourse = await _createCourseService.createCourse(
        title: title,
        courseCode: courseCode,
        credit: credit,
        description: description,
        excerpt: excerpt,
        imageFile: imageFile,
      );
      stateNotifier.value = CreateCourseState.success;
    } catch (error) {
      errorMessage = error.toString();
      stateNotifier.value = CreateCourseState.error;
    }
  }
}
