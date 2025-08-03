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
  
  void dispose() {
    _disposed = true;
    _stateNotifier.dispose();
  }
}