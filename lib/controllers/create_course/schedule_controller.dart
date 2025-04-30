import 'package:classmate/models/create_course/schedule_model.dart';
import 'package:classmate/services/create_course/schedule_service.dart';
import 'package:flutter/material.dart';

enum ScheduleState { idle, loading, success, error }

class ScheduleController {
  final ScheduleService _scheduleService = ScheduleService();

  final ValueNotifier<ScheduleState> stateNotifier =
  ValueNotifier<ScheduleState>(ScheduleState.idle);

  String? errorMessage;
  ScheduleModel? createdSchedule;

  // Create a schedule
  Future<void> createSchedule(ScheduleModel schedule) async {
    stateNotifier.value = ScheduleState.loading;
    try {

      createdSchedule = await _scheduleService.createSchedule(schedule);

      stateNotifier.value = ScheduleState.success;
    } catch (error) {
      errorMessage = error.toString();
      stateNotifier.value = ScheduleState.error;
    }
  }


}
