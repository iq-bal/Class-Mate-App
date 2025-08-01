import 'dart:io';

import 'package:classmate/models/profile_teacher/profile_teacher_model.dart';
import 'package:classmate/services/profile_teacher/profile_teacher_service.dart';
import 'package:flutter/material.dart';

enum ProfileTeacherState { idle, loading, success, error }

class ProfileTeacherController {
  final ProfileTeacherService _profileTeacherService = ProfileTeacherService();

  final ValueNotifier<ProfileTeacherState> stateNotifier =
  ValueNotifier<ProfileTeacherState>(ProfileTeacherState.idle);

  String? errorMessage;
  ProfileTeacherModel? teacherProfile;

  Future<void> fetchTeacherProfile() async {
    stateNotifier.value = ProfileTeacherState.loading;
    try {
      teacherProfile = await _profileTeacherService.fetchTeacherProfile();
      stateNotifier.value = ProfileTeacherState.success;
    } catch (error) {
      errorMessage = error.toString();
      stateNotifier.value = ProfileTeacherState.error;
    }
  }


  Future<void> updateProfilePicture(File imageFile) async {
    stateNotifier.value = ProfileTeacherState.loading;
    try {
      String url = await _profileTeacherService.updateProfilePicture(imageFile);
      if (teacherProfile != null) {
        teacherProfile!.profilePicture = url;
      }
      stateNotifier.value = ProfileTeacherState.success;
    } catch (error) {
      errorMessage = error.toString();
      stateNotifier.value = ProfileTeacherState.error;
    }
  }


  Future<void> updateCoverPhoto(File imageFile) async {
    stateNotifier.value = ProfileTeacherState.loading;
    try {
      String url = await _profileTeacherService.updateCoverPhoto(imageFile);
      if (teacherProfile != null) {
        teacherProfile!.coverPicture = url;
      }
      stateNotifier.value = ProfileTeacherState.success;
    } catch (error) {
      errorMessage = error.toString();
      stateNotifier.value = ProfileTeacherState.error;
    }
  }


  /// Updates only the `about` field.
  Future<void> updateTeacherAbout(String about) async {
    stateNotifier.value = ProfileTeacherState.loading;
    try {
      await _profileTeacherService.updateTeacherAbout(about);
      // update local model so UI reflects change immediately
      if (teacherProfile != null) {
        teacherProfile!.teacher?.about = about;
      }
      stateNotifier.value = ProfileTeacherState.success;
    } catch (error) {
      errorMessage = error.toString();
      stateNotifier.value = ProfileTeacherState.error;
    }
  }

  /// Updates only the `department` field.
  Future<void> updateTeacherDepartment(String department) async {
    stateNotifier.value = ProfileTeacherState.loading;
    try {
      await _profileTeacherService.updateTeacherDepartment(department);
      if (teacherProfile != null) {
        teacherProfile!.teacher?.department = department;
      }
      stateNotifier.value = ProfileTeacherState.success;
    } catch (error) {
      errorMessage = error.toString();
      stateNotifier.value = ProfileTeacherState.error;
    }
  }

  /// Updates only the `designation` field.
  Future<void> updateTeacherDesignation(String designation) async {
    stateNotifier.value = ProfileTeacherState.loading;
    try {
      await _profileTeacherService.updateTeacherDesignation(designation);
      if (teacherProfile != null) {
        teacherProfile!.teacher?.designation = designation;
      }
      stateNotifier.value = ProfileTeacherState.success;
    } catch (error) {
      errorMessage = error.toString();
      stateNotifier.value = ProfileTeacherState.error;
    }
  }

  /// Deletes a course and updates the local state
  Future<void> deleteCourse(String courseId) async {
    stateNotifier.value = ProfileTeacherState.loading;
    try {
      await _profileTeacherService.deleteCourse(courseId);
      if (teacherProfile != null && teacherProfile!.courses != null) {
        teacherProfile!.courses!.removeWhere((course) => course.id == courseId);
      }
      stateNotifier.value = ProfileTeacherState.success;
    } catch (error) {
      errorMessage = error.toString();
      stateNotifier.value = ProfileTeacherState.error;
    }
  }
}
