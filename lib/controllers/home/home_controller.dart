import 'package:flutter/foundation.dart';
import 'package:classmate/models/home/home_page_model.dart';
import 'package:classmate/services/home/home_service.dart';

enum HomeState { idle, loading, success, error }

class HomeController {
  final HomeService _homeService = HomeService();
  
  final ValueNotifier<HomeState> _stateNotifier = ValueNotifier(HomeState.idle);
  ValueNotifier<HomeState> get stateNotifier => _stateNotifier;
  bool _disposed = false;
  
  HomePageModel? _homePageData;
  HomePageModel? get homePageData => _homePageData;
  
  HomePageModel? _assignmentsData;
  HomePageModel? get assignmentsData => _assignmentsData;
  
  HomePageModel? _classTestsData;
  HomePageModel? get classTestsData => _classTestsData;
  
  Map<String, dynamic>? _currentClassData;
  Map<String, dynamic>? get currentClassData => _currentClassData;
  
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  
  // Helper getters for easy access to data
  List<CourseHomeModel> get allCourses {
    if (_homePageData == null) return [];
    return _homePageData!.enrollments
        .where((enrollment) => enrollment.status.toLowerCase() == 'approved')
        .expand((enrollment) => enrollment.courses)
        .toList();
  }
  
  List<AssignmentHomeModel> get allAssignments {
    if (_assignmentsData == null) return [];
    return _assignmentsData!.enrollments
        .where((enrollment) => enrollment.status.toLowerCase() == 'approved')
        .expand((enrollment) => enrollment.courses)
        .expand((course) => course.assignments)
        .toList();
  }
  
  List<ClassTestHomeModel> get allClassTests {
    if (_classTestsData == null) return [];
    return _classTestsData!.enrollments
        .where((enrollment) => enrollment.status.toLowerCase() == 'approved')
        .expand((enrollment) => enrollment.courses)
        .expand((course) => course.classTests)
        .toList();
  }
  
  // Get user information
  UserHomeModel? get user => _homePageData?.user;
  
  // Get all schedules from today's courses
  List<ScheduleHomeModel> get allSchedules {
    return allCourses.expand((course) => course.schedules).toList();
  }
  
  // Get next class based on current day and time
  ScheduleHomeModel? get nextClass {
    final schedules = allSchedules;
    if (schedules.isEmpty) return null;
    
    // For now, return the first schedule
    // You can implement more sophisticated logic based on current time
    return schedules.first;
  }
  
  // Get course for a specific schedule
  CourseHomeModel? getCourseForSchedule(ScheduleHomeModel schedule) {
    for (final course in allCourses) {
      if (course.schedules.any((s) => s.id == schedule.id)) {
        return course;
      }
    }
    return null;
  }
  
  // Fetch today's enrolled courses
  Future<void> fetchTodaysEnrolledCourses(String day) async {
    if (_disposed) return;
    _stateNotifier.value = HomeState.loading;
    try {
      final data = await _homeService.getTodaysEnrolledCourses(day);
      if (_disposed) return;
      if (data != null) {
        _homePageData = data;
        _stateNotifier.value = HomeState.success;
      } else {
        _stateNotifier.value = HomeState.error;
      }
    } catch (e) {
      print('Error fetching today\'s enrolled courses: $e');
      if (!_disposed) {
        _stateNotifier.value = HomeState.error;
      }
    }
  }
  
  // Fetch all student assignments
  Future<void> fetchStudentAllAssignments() async {
    try {
      final data = await _homeService.getStudentAllAssignments();
      if (_disposed) return;
      if (data != null) {
        _assignmentsData = data;
        print('Assignments data fetched: ${_assignmentsData!.enrollments.length} enrollments');
        final assignmentCount = allAssignments.length;
        print('Total assignments found: $assignmentCount');
      } else {
        print('No assignments data received');
      }
    } catch (e) {
      print('Error fetching student assignments: $e');
    }
  }
  
  // Fetch all student class tests
  Future<void> fetchStudentAllClassTests() async {
    try {
      final data = await _homeService.getStudentAllClassTests();
      if (_disposed) return;
      if (data != null) {
        _classTestsData = data;
        print('Class tests data fetched: ${_classTestsData!.enrollments.length} enrollments');
        final classTestCount = allClassTests.length;
        print('Total class tests found: $classTestCount');
      } else {
        print('No class tests data received');
      }
    } catch (e) {
      print('Error fetching student class tests: $e');
    }
  }
  
  // Fetch current class for student
  Future<void> fetchCurrentClass(String day, String currentTime) async {
    try {
      final data = await _homeService.getCurrentClassForStudent(day, currentTime);
      if (_disposed) return;
      if (data != null) {
        _currentClassData = data;
        print('Current class data fetched: ${data.toString()}');
      } else {
        print('No current class data received');
        _currentClassData = null;
      }
    } catch (e) {
      print('Error fetching current class: $e');
      if (!_disposed) {
        _currentClassData = null;
      }
    }
  }
  
  Future<void> fetchHomePageData() async {
    try {
      if (_disposed) return;
      _stateNotifier.value = HomeState.loading;
      _errorMessage = null;
      
      _homePageData = await _homeService.getHomePageData();
      
      if (!_disposed) {
        _stateNotifier.value = HomeState.success;
      }
    } catch (e) {
      if (!_disposed) {
        _errorMessage = e.toString();
        _stateNotifier.value = HomeState.error;
      }
    }
  }
  
  void dispose() {
    _disposed = true;
    _stateNotifier.dispose();
  }
}