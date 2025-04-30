import 'package:classmate/models/create_course/syllabus_model.dart';
import 'package:classmate/services/create_course/syllabus_service.dart';
import 'package:flutter/material.dart';

enum SyllabusState { idle, loading, success, error }

class SyllabusController {
  final SyllabusService _syllabusService = SyllabusService();

  final ValueNotifier<SyllabusState> stateNotifier =
  ValueNotifier<SyllabusState>(SyllabusState.idle);

  String? errorMessage;
  SyllabusModel? syllabusModel;

  Future<void> updateSyllabus({
    required String courseId,
    required Map<String, List<String>> syllabusData,
  }) async {

    stateNotifier.value = SyllabusState.loading;
    try {

      syllabusModel = await _syllabusService.updateSyllabus(
        courseId: courseId,
        syllabusData: syllabusData,
      );
      stateNotifier.value = SyllabusState.success;
    } catch (error) {
      errorMessage = error.toString();
      stateNotifier.value = SyllabusState.error;
    }
  }
}
