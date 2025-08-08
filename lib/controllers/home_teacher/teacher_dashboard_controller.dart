import 'package:flutter/foundation.dart';
import 'package:classmate/models/home_teacher/teacher_dashboard_model.dart';
import 'package:classmate/services/home_teacher/teacher_dashboard_service.dart';

enum TeacherDashboardState { idle, loading, success, error }

class TeacherDashboardController {
  final TeacherDashboardService _service = TeacherDashboardService();
  
  final ValueNotifier<TeacherDashboardState> _stateNotifier = ValueNotifier(TeacherDashboardState.idle);
  ValueNotifier<TeacherDashboardState> get stateNotifier => _stateNotifier;
  
  TeacherDashboardModel? _dashboardData;
  TeacherDashboardModel? get dashboardData => _dashboardData;
  
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  
  List<CourseModel> get courses {
    return _dashboardData?.user.courses ?? [];
  }
  
  bool _disposed = false;
  
  Future<void> fetchMyCreatedCourses() async {
    if (_disposed) return;
    
    _stateNotifier.value = TeacherDashboardState.loading;
    _errorMessage = null;
    
    try {
      final data = await _service.getMyCreatedCourses();
      if (_disposed) return;
      
      if (data != null) {
        _dashboardData = data;
        _stateNotifier.value = TeacherDashboardState.success;
      } else {
        _errorMessage = 'No data received';
        _stateNotifier.value = TeacherDashboardState.error;
      }
    } catch (e) {
      if (_disposed) return;
      _errorMessage = e.toString();
      _stateNotifier.value = TeacherDashboardState.error;
      print('Error fetching teacher courses: $e');
    }
  }
  
  Future<bool> updateCourse({
    required String courseId,
    required String title,
    required String courseCode,
    required String description,
    required int credit,
    required String excerpt,
    required Map<String, List<String>> syllabus,
  }) async {
    if (_disposed) return false;
    
    try {
      final updatedCourse = await _service.updateCourse(
        courseId: courseId,
        title: title,
        courseCode: courseCode,
        description: description,
        credit: credit,
        excerpt: excerpt,
        syllabus: syllabus,
      );
      
      if (updatedCourse != null && _dashboardData != null) {
        // Update the course in the local data
        final courseIndex = _dashboardData!.user.courses.indexWhere((course) => course.id == courseId);
        if (courseIndex != -1) {
          // Create a new list with the updated course
          final updatedCourses = List<CourseModel>.from(_dashboardData!.user.courses);
          updatedCourses[courseIndex] = updatedCourse;
          
          // Update the dashboard data
          _dashboardData = TeacherDashboardModel(
            user: UserModel(courses: updatedCourses),
          );
          
          _stateNotifier.value = TeacherDashboardState.success;
          return true;
        }
      }
      return false;
    } catch (e) {
      if (_disposed) return false;
      _errorMessage = e.toString();
      print('Error updating course: $e');
      return false;
    }
  }
  
  void dispose() {
    _disposed = true;
    _stateNotifier.dispose();
  }
}