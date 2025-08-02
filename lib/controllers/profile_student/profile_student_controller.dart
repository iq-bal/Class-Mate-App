import 'dart:io';

import 'package:classmate/models/profile_student/profile_student_model.dart';
import 'package:classmate/services/profile_student/profile_student_service.dart';
import 'package:flutter/material.dart';

enum ProfileStudentState { idle, loading, success, error }

class ProfileStudentController {
  final ProfileStudentService _profileStudentService = ProfileStudentService();

  final ValueNotifier<ProfileStudentState> stateNotifier =
      ValueNotifier<ProfileStudentState>(ProfileStudentState.idle);

  String? errorMessage;
  ProfileStudentModel? studentProfile;

  Future<void> fetchStudentProfile() async {
    stateNotifier.value = ProfileStudentState.loading;
    try {
      studentProfile = await _profileStudentService.fetchStudentProfile();
      stateNotifier.value = ProfileStudentState.success;
    } catch (error) {
      errorMessage = error.toString();
      stateNotifier.value = ProfileStudentState.error;
    }
  }

  Future<void> updateProfilePicture(File imageFile) async {
    stateNotifier.value = ProfileStudentState.loading;
    try {
      String url = await _profileStudentService.updateProfilePicture(imageFile);
      if (studentProfile != null) {
        studentProfile = ProfileStudentModel(
          id: studentProfile!.id,
          roll: studentProfile!.roll,
          section: studentProfile!.section,
          name: studentProfile!.name,
          email: studentProfile!.email,
          profilePicture: url,
          about: studentProfile!.about,
          department: studentProfile!.department,
          semester: studentProfile!.semester,
          cgpa: studentProfile!.cgpa,
          userId: UserModel(
            id: studentProfile!.userId.id,
            name: studentProfile!.userId.name,
            email: studentProfile!.userId.email,
            profilePicture: url,
            coverPicture: studentProfile!.userId.coverPicture,
          ),
          enrollments: studentProfile!.enrollments,
        );
      }
      stateNotifier.value = ProfileStudentState.success;
    } catch (error) {
      errorMessage = error.toString();
      stateNotifier.value = ProfileStudentState.error;
    }
  }

  Future<void> updateCoverPhoto(File imageFile) async {
    stateNotifier.value = ProfileStudentState.loading;
    try {
      String url = await _profileStudentService.updateCoverPhoto(imageFile);
      if (studentProfile != null) {
        studentProfile = ProfileStudentModel(
          id: studentProfile!.id,
          roll: studentProfile!.roll,
          section: studentProfile!.section,
          name: studentProfile!.name,
          email: studentProfile!.email,
          profilePicture: studentProfile!.profilePicture,
          about: studentProfile!.about,
          department: studentProfile!.department,
          semester: studentProfile!.semester,
          cgpa: studentProfile!.cgpa,
          userId: UserModel(
            id: studentProfile!.userId.id,
            name: studentProfile!.userId.name,
            email: studentProfile!.userId.email,
            profilePicture: studentProfile!.userId.profilePicture,
            coverPicture: url,
          ),
          enrollments: studentProfile!.enrollments,
        );
      }
      stateNotifier.value = ProfileStudentState.success;
    } catch (error) {
      errorMessage = error.toString();
      stateNotifier.value = ProfileStudentState.error;
    }
  }

  Future<void> updateAbout(String about) async {
    stateNotifier.value = ProfileStudentState.loading;
    try {
      await _profileStudentService.updateStudentAbout(about);
      if (studentProfile != null) {
        studentProfile = ProfileStudentModel(
          id: studentProfile!.id,
          roll: studentProfile!.roll,
          section: studentProfile!.section,
          name: studentProfile!.name,
          email: studentProfile!.email,
          profilePicture: studentProfile!.profilePicture,
          about: about,
          department: studentProfile!.department,
          semester: studentProfile!.semester,
          cgpa: studentProfile!.cgpa,
          userId: studentProfile!.userId,
          enrollments: studentProfile!.enrollments,
        );
      }
      stateNotifier.value = ProfileStudentState.success;
    } catch (error) {
      errorMessage = error.toString();
      stateNotifier.value = ProfileStudentState.error;
    }
  }

  Future<void> updateStudentInfo({
    String? roll,
    String? section,
    String? department,
    String? semester,
    String? cgpa,
  }) async {
    stateNotifier.value = ProfileStudentState.loading;
    try {
      final updatedProfile = await _profileStudentService.updateStudentInfo(
        roll: roll,
        section: section,
        department: department,
        semester: semester,
        cgpa: cgpa,
      );
      
      // Update the current profile with new data while preserving other fields
      if (studentProfile != null) {
        studentProfile = ProfileStudentModel(
          id: updatedProfile.id,
          roll: updatedProfile.roll,
          section: updatedProfile.section,
          name: updatedProfile.name,
          email: updatedProfile.email,
          profilePicture: studentProfile!.profilePicture,
          about: studentProfile!.about,
          department: updatedProfile.department,
          semester: updatedProfile.semester,
          cgpa: updatedProfile.cgpa,
          userId: updatedProfile.userId,
          enrollments: studentProfile!.enrollments,
        );
      }
      stateNotifier.value = ProfileStudentState.success;
    } catch (error) {
      errorMessage = error.toString();
      stateNotifier.value = ProfileStudentState.error;
    }
  }

  Future<void> updateStudentAbout(String about) async {
    stateNotifier.value = ProfileStudentState.loading;
    try {
      final updatedProfile = await _profileStudentService.updateStudentAbout(about);
      
      // Update the current profile with new about data while preserving other fields
      if (studentProfile != null) {
        studentProfile = ProfileStudentModel(
          id: updatedProfile.id,
          roll: updatedProfile.roll,
          section: updatedProfile.section,
          name: updatedProfile.name,
          email: updatedProfile.email,
          profilePicture: studentProfile!.profilePicture,
          about: updatedProfile.about,
          department: updatedProfile.department,
          semester: updatedProfile.semester,
          cgpa: updatedProfile.cgpa,
          userId: updatedProfile.userId,
          enrollments: studentProfile!.enrollments,
        );
      }
      stateNotifier.value = ProfileStudentState.success;
    } catch (error) {
      errorMessage = error.toString();
      stateNotifier.value = ProfileStudentState.error;
    }
  }
}