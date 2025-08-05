import 'package:flutter/foundation.dart';
import 'package:classmate/models/course_detail_teacher/enrollment_model.dart';
import 'package:classmate/services/attendance/attendance_service.dart';
import 'package:classmate/services/attendance/session_service.dart';
import 'package:classmate/services/realtime_attendance_service.dart';

enum AttendanceState {
  initial,
  loading,
  success,
  error,
}

class AttendanceController {
  final AttendanceService _attendanceService = AttendanceService();
  final SessionService _sessionService = SessionService();
  final RealtimeAttendanceService _realtimeService = RealtimeAttendanceService();
  final ValueNotifier<AttendanceState> _stateNotifier = ValueNotifier(AttendanceState.initial);
  
  List<EnrollmentModel> _approvedStudents = [];
  String? _errorMessage;
  Map<String, String> _studentAttendanceStatus = {}; // studentId -> status (present/absent)
  
  ValueNotifier<AttendanceState> get stateNotifier => _stateNotifier;
  List<EnrollmentModel> get approvedStudents => _approvedStudents;
  String? get errorMessage => _errorMessage;
  
  int get presentCount => _studentAttendanceStatus.values.where((status) => status == 'present').length;
  int get absentCount => _studentAttendanceStatus.values.where((status) => status == 'absent').length;
  
  String? getStudentAttendanceStatus(String studentId) {
    return _studentAttendanceStatus[studentId];
  }
  
  Future<void> fetchApprovedStudents(String courseId) async {
    try {
      _stateNotifier.value = AttendanceState.loading;
      _errorMessage = null;
      
      final enrollments = await _attendanceService.getApprovedStudents(courseId);
      _approvedStudents = enrollments;
      _studentAttendanceStatus.clear(); // Reset attendance status
      
      _stateNotifier.value = AttendanceState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _stateNotifier.value = AttendanceState.error;
      if (kDebugMode) {
        print('Error fetching approved students: $e');
      }
    }
  }
  
  Future<String?> startAttendanceSession(String courseId) async {
    try {
      // First create a session
      final now = DateTime.now();
      final date = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final startTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      final endTime = '${(now.hour + 1).toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      
      final session = await _sessionService.createSession(
        courseId: courseId,
        title: 'Attendance Session',
        description: 'Real-time attendance tracking session',
        date: date,
        startTime: startTime,
        endTime: endTime,
        meetingLink: 'https://zoom.us/j/123456789',
      );
      
      if (session.id == null) {
        throw Exception('Failed to create session: No session ID returned');
      }

      print("----------- ever came here: ${session.id} -------------");
      
      // Initialize realtime service and start the session (for teacher)
         await _realtimeService.initializeAttendanceSocket();
         
         // Wait for socket to be connected before starting session
         int attempts = 0;
         while (!_realtimeService.isConnected && attempts < 10) {
           await Future.delayed(const Duration(milliseconds: 500));
           attempts++;
         }
         
         if (_realtimeService.isConnected) {
           // Set up event listeners for real-time updates
           _setupRealtimeListeners();
           _realtimeService.startAttendanceSession(session.id!);
         } else {
           throw Exception('Failed to connect to attendance socket');
         }
      
      _studentAttendanceStatus.clear(); // Reset attendance status for new session
      return session.id;
    } catch (e) {
      if (kDebugMode) {
        print('Error starting attendance session: $e');
      }
      rethrow;
    }
  }
  
  Future<void> endAttendanceSession(String sessionId) async {
    try {
      await _attendanceService.endAttendanceSession(sessionId);
    } catch (e) {
      if (kDebugMode) {
        print('Error ending attendance session: $e');
      }
      rethrow;
    }
  }
  
  Future<void> markAttendance(String sessionId, String studentId, String status) async {
    try {
      await _attendanceService.markAttendance(sessionId, studentId, status);
      _studentAttendanceStatus[studentId] = status;
      // Trigger UI update
      _stateNotifier.value = AttendanceState.success;
    } catch (e) {
      if (kDebugMode) {
        print('Error marking attendance: $e');
      }
      rethrow;
    }
  }
  
  // Setup real-time event listeners for attendance session
  void _setupRealtimeListeners() {
    // Listen for attendance session started confirmation
    _realtimeService.onAttendanceSessionStarted((data) {
      if (kDebugMode) {
        print('Attendance session started: $data');
      }
      // Update UI state if needed
      _stateNotifier.value = AttendanceState.success;
    });
    
    // Listen for students joining the session
    _realtimeService.onStudentJoined((data) {
      if (kDebugMode) {
        print('Student joined attendance: $data');
      }
      final studentId = data['student_id'] as String?;
      if (studentId != null) {
        // Mark student as present when they join
        _studentAttendanceStatus[studentId] = 'present';
        _stateNotifier.value = AttendanceState.success; // Trigger UI update
      }
    });
    
    // Listen for students leaving the session
    _realtimeService.onStudentLeft((data) {
      if (kDebugMode) {
        print('Student left attendance: $data');
      }
      final studentId = data['student_id'] as String?;
      if (studentId != null) {
        // Mark student as absent when they leave
        _studentAttendanceStatus[studentId] = 'absent';
        _stateNotifier.value = AttendanceState.success; // Trigger UI update
      }
    });
    
    // Listen for attendance updates
    _realtimeService.onAttendanceUpdated((data) {
      if (kDebugMode) {
        print('Attendance updated: $data');
      }
      final studentId = data['student_id'] as String?;
      final status = data['status'] as String?;
      if (studentId != null && status != null) {
        _studentAttendanceStatus[studentId] = status;
        _stateNotifier.value = AttendanceState.success; // Trigger UI update
      }
    });
    
    // Listen for attendance session ended
    _realtimeService.onAttendanceSessionEnded((data) {
      if (kDebugMode) {
        print('Attendance session ended: $data');
      }
      // Clear listeners and reset state
      _realtimeService.removeAllListeners();
    });
    
    // Listen for errors
    _realtimeService.onAttendanceError((data) {
      if (kDebugMode) {
        print('Attendance error: $data');
      }
      _errorMessage = data['message'] as String? ?? 'Unknown attendance error';
      _stateNotifier.value = AttendanceState.error;
    });
  }

  void dispose() {
    _realtimeService.removeAllListeners();
    _stateNotifier.dispose();
  }
}