import 'package:flutter/foundation.dart';
import 'package:classmate/models/course_detail_teacher/enrollment_model.dart';
import 'package:classmate/services/course_detail_teacher/enrollment_service.dart';

enum EnrollmentState { idle, loading, success, error }

class EnrollmentController {
  final EnrollmentService _enrollmentService = EnrollmentService();
  
  final ValueNotifier<EnrollmentState> _stateNotifier = ValueNotifier(EnrollmentState.idle);
  ValueNotifier<EnrollmentState> get stateNotifier => _stateNotifier;
  
  List<EnrollmentModel> _enrollments = [];
  List<EnrollmentModel> get enrollments => _enrollments;
  
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  
  // Filtered lists based on status
  List<EnrollmentModel> get approvedStudents => 
      _enrollments.where((enrollment) => enrollment.status.toLowerCase() == 'approved').toList();
  
  List<EnrollmentModel> get pendingStudents => 
      _enrollments.where((enrollment) => enrollment.status.toLowerCase() == 'pending').toList();
  
  List<EnrollmentModel> get rejectedStudents => 
      _enrollments.where((enrollment) => enrollment.status.toLowerCase() == 'rejected').toList();
  
  Future<void> fetchEnrollments(String courseId) async {
    try {
      _stateNotifier.value = EnrollmentState.loading;
      _errorMessage = null;
      
      _enrollments = await _enrollmentService.getCourseEnrollments(courseId);
      
      _stateNotifier.value = EnrollmentState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _stateNotifier.value = EnrollmentState.error;
    }
  }
  
  Future<bool> updateEnrollmentStatus(String enrollmentId, String status, String courseId) async {
    try {
      final success = await _enrollmentService.updateEnrollmentStatus(enrollmentId, status);
      if (success) {
        // Refresh the enrollments list after successful update
        await fetchEnrollments(courseId);
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }
  
  void dispose() {
    _stateNotifier.dispose();
  }
}