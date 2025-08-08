import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:classmate/services/realtime_attendance_service.dart';
import 'package:classmate/services/notification_service.dart';
import 'package:classmate/models/attendance/attendance_session_model.dart';
import 'package:classmate/core/token_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:classmate/services/attendance/session_service.dart';
import 'package:classmate/services/attendance/attendance_service.dart';
import 'package:classmate/services/attendance/session_service.dart';

class RealtimeAttendanceController {
  final RealtimeAttendanceService _socketService = RealtimeAttendanceService();
  final NotificationService _notificationService = NotificationService();
  final TokenStorage _tokenStorage = TokenStorage();
  final SessionService _sessionService = SessionService();
  final AttendanceService _attendanceService = AttendanceService();
  
  // Student state
  final ValueNotifier<bool> isSessionActive = ValueNotifier(false);
  final ValueNotifier<String?> activeSessionId = ValueNotifier(null);
  final ValueNotifier<String?> activeCourseId = ValueNotifier(null);
  final ValueNotifier<String?> activeSessionTopic = ValueNotifier(null);
  final ValueNotifier<bool> hasJoinedSession = ValueNotifier(false);
  
  // Teacher state
  final ValueNotifier<List<OnlineStudent>> onlineStudents = ValueNotifier([]);
  final ValueNotifier<Map<String, String>> attendanceStatus = ValueNotifier({});
  final ValueNotifier<bool> isTeacherSessionActive = ValueNotifier(false);
  final ValueNotifier<String?> teacherActiveSessionId = ValueNotifier(null);
  final ValueNotifier<AttendanceStatistics?> sessionStatistics = ValueNotifier(null);
  
  // Common state
  final ValueNotifier<bool> isConnected = ValueNotifier(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier(null);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  
  // Current user info
  String? _currentUserId;
  String? _currentUserRole;
  
  // Initialize the controller
  Future<void> initialize() async {
    try {
      print("DEBUG 1");
      isLoading.value = true;
      await _loadUserInfo();
      print("DEBUG 2");
      await _socketService.initializeAttendanceSocket();
      _setupEventListeners();
      isConnected.value = _socketService.isConnected;
    } catch (e) {
      errorMessage.value = 'Failed to initialize: $e';
      debugPrint('RealtimeAttendanceController initialization error: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Load current user information from token
  Future<void> _loadUserInfo() async {
    try {
      final token = await _tokenStorage.retrieveAccessToken();
     
      if (token != null) {
        final decodedToken = JwtDecoder.decode(token);
        _currentUserId = decodedToken['id'] ?? decodedToken['userId'];
        _currentUserRole = decodedToken['role'];
      }
    } catch (e) {
      debugPrint('Failed to load user info: $e');
    }
  }
  
  // Setup socket event listeners
  void _setupEventListeners() {
    // Connection events
    _socketService.socket?.on('connect', (_) {
      isConnected.value = true;
      errorMessage.value = null;
    });
    
    _socketService.socket?.on('disconnect', (_) {
      isConnected.value = false;
    });
    
    _socketService.socket?.on('connect_error', (data) {
      isConnected.value = false;
      errorMessage.value = 'Connection error: $data';
    });
    
    // Student events
    _socketService.onAttendanceSessionStarted(_handleSessionStarted);
    _socketService.onAttendanceSessionEnded(_handleSessionEnded);
    _socketService.onAttendanceSessionEndedConfirm(_handleSessionEndedConfirm);
    _socketService.onAttendanceMarked(_handleAttendanceMarked);
    
    // Teacher events
    _socketService.onStudentJoined(_handleStudentJoined);
    _socketService.onStudentLeft(_handleStudentLeft);
    _socketService.onAttendanceUpdated(_handleAttendanceUpdated);
    _socketService.onOnlineStudentsUpdated(_handleOnlineStudentsUpdated);
    _socketService.onOnlineStudentsData(_handleOnlineStudentsData);
    
    // Attendance marking events
    _socketService.onStudentMarkedPresent(_handleStudentMarkedPresent);
    _socketService.onStudentMarkedAbsent(_handleStudentMarkedAbsent);
    
    // Error events
    _socketService.onAttendanceError(_handleAttendanceError);
  }
  
  // Student Methods
  
  // Join an attendance session
  Future<void> joinSession(String sessionId) async {
    if (_currentUserId == null) {
      errorMessage.value = 'User not authenticated';
      return;
    }
    
    try {
      _socketService.joinAttendanceSession(sessionId, _currentUserId!);
      hasJoinedSession.value = true;
      
      // Show notification
      _showLocalNotification(
        title: 'Joined Class Session',
        body: 'You have successfully joined the attendance session',
      );
    } catch (e) {
      errorMessage.value = 'Failed to join session: $e';
    }
  }
  
  // Leave an attendance session
  Future<void> leaveSession() async {
    if (_currentUserId == null || activeSessionId.value == null) {
      return;
    }
    
    try {
      _socketService.leaveAttendanceSession(activeSessionId.value!, _currentUserId!);
      hasJoinedSession.value = false;
    } catch (e) {
      errorMessage.value = 'Failed to leave session: $e';
    }
  }
  
  // Teacher Methods
  
  // Start an attendance session by first creating a session, then starting attendance
  Future<void> startSession({
    required String courseId,
    required String topic,
    String? description,
    DateTime? date,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String? meetingLink,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      // First create a session using SessionService
      final sessionDate = date ?? DateTime.now();
      final sessionStartTime = startTime ?? TimeOfDay.now();
      final sessionEndTime = endTime ?? TimeOfDay(hour: DateTime.now().hour + 1, minute: DateTime.now().minute);
      
      final session = await _sessionService.createSession(
        courseId: courseId,
        title: topic,
        description: description ?? 'Attendance session for $topic',
        date: '${sessionDate.year}-${sessionDate.month.toString().padLeft(2, '0')}-${sessionDate.day.toString().padLeft(2, '0')}',
        startTime: '${sessionStartTime.hour.toString().padLeft(2, '0')}:${sessionStartTime.minute.toString().padLeft(2, '0')}',
        endTime: '${sessionEndTime.hour.toString().padLeft(2, '0')}:${sessionEndTime.minute.toString().padLeft(2, '0')}',
        meetingLink: meetingLink,
      );
      
      // Then start the attendance session with the session ID
      if (session.id == null) {
        throw Exception('Session creation failed: No session ID returned');
      }
      final sessionId = await _attendanceService.startAttendanceSession(session.id!);
      
      // Start Socket.IO attendance session with the session ID
      _socketService.startAttendanceSession(sessionId);
      
      // Update teacher state
      isTeacherSessionActive.value = true;
      teacherActiveSessionId.value = sessionId;
      activeCourseId.value = courseId;
      activeSessionTopic.value = topic;
      
    } catch (e) {
      errorMessage.value = 'Failed to start session: $e';
      debugPrint('Error starting session: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  // End an attendance session
  Future<void> endSession() async {
    if (teacherActiveSessionId.value == null) {
      return;
    }
    
    try {
      isLoading.value = true;
      _socketService.endAttendanceSession(teacherActiveSessionId.value!);
      
      // Reset teacher state
      isTeacherSessionActive.value = false;
      teacherActiveSessionId.value = null;
      onlineStudents.value = [];
      attendanceStatus.value = {};
      sessionStatistics.value = null;
      
    } catch (e) {
      errorMessage.value = 'Failed to end session: $e';
    } finally {
      isLoading.value = false;
    }
  }
  
  // Mark student attendance
  Future<void> markAttendance(String studentId, String status, {String? remarks}) async {
    if (teacherActiveSessionId.value == null) {
      errorMessage.value = 'No active session';
      return;
    }
    
    try {
      _socketService.markStudentAttendance(
        teacherActiveSessionId.value!,
        studentId,
        status,
        remarks: remarks,
      );
      
      // Update local state immediately for better UX
      final currentStatus = Map<String, String>.from(attendanceStatus.value);
      currentStatus[studentId] = status;
      attendanceStatus.value = currentStatus;
      
    } catch (e) {
      errorMessage.value = 'Failed to mark attendance: $e';
    }
  }

  // Mark student present (using specific socket endpoint)
  Future<void> markStudentPresent(String studentId) async {
    if (teacherActiveSessionId.value == null) {
      errorMessage.value = 'No active session';
      return;
    }
    
    try {
      _socketService.markStudentPresent(
        teacherActiveSessionId.value!,
        studentId,
      );
      
      // Update local state immediately for better UX
      final currentStatus = Map<String, String>.from(attendanceStatus.value);
      currentStatus[studentId] = 'present';
      attendanceStatus.value = currentStatus;
      
    } catch (e) {
      errorMessage.value = 'Failed to mark student present: $e';
    }
  }

  // Mark student absent (using specific socket endpoint)
  Future<void> markStudentAbsent(String studentId) async {
    if (teacherActiveSessionId.value == null) {
      errorMessage.value = 'No active session';
      return;
    }
    
    try {
      _socketService.markStudentAbsent(
        teacherActiveSessionId.value!,
        studentId,
      );
      
      // Update local state immediately for better UX
      final currentStatus = Map<String, String>.from(attendanceStatus.value);
      currentStatus[studentId] = 'absent';
      attendanceStatus.value = currentStatus;
      
    } catch (e) {
      errorMessage.value = 'Failed to mark student absent: $e';
    }
  }

  // Request online students from server
  void requestOnlineStudents() {
    if (teacherActiveSessionId.value == null) {
      debugPrint('No active session to request online students');
      return;
    }
    
    _socketService.getOnlineStudents(teacherActiveSessionId.value!);
    debugPrint('Requesting online students for session: ${teacherActiveSessionId.value}');
  }
  
  // Event Handlers
  
  void _handleSessionStarted(Map<String, dynamic> data) {
    try {
      final sessionId = data['session_id'] as String?;
      final session = data['session'] as Map<String, dynamic>?;
      
      if (sessionId != null && session != null) {
        final courseId = session['course_id'] is Map 
            ? session['course_id']['_id'] as String?
            : session['course_id'] as String?;
        final topic = session['topic'] as String?;
        
        // Update student state
        isSessionActive.value = true;
        activeSessionId.value = sessionId;
        activeCourseId.value = courseId;
        activeSessionTopic.value = topic;
        
        // Update teacher state if this user is the teacher
        if (_currentUserRole == 'teacher') {
          isTeacherSessionActive.value = true;
          teacherActiveSessionId.value = sessionId;
        }
        
        // Show notification for students
        if (_currentUserRole == 'student') {
          _showLocalNotification(
            title: 'Class Session Started',
            body: 'A new attendance session has started for ${topic ?? 'your class'}. Tap to join!',
          );
        }
      }
    } catch (e) {
      debugPrint('Error handling session started: $e');
    }
  }
  
  void _handleSessionEnded(Map<String, dynamic> data) {
    try {
      // Reset all state
      isSessionActive.value = false;
      activeSessionId.value = null;
      activeCourseId.value = null;
      activeSessionTopic.value = null;
      hasJoinedSession.value = false;
      
      // Reset teacher state
      isTeacherSessionActive.value = false;
      teacherActiveSessionId.value = null;
      onlineStudents.value = [];
      attendanceStatus.value = {};
      sessionStatistics.value = null;
      
      // Show notification
      _showLocalNotification(
        title: 'Session Ended',
        body: 'The attendance session has ended.',
      );
    } catch (e) {
      debugPrint('Error handling session ended: $e');
    }
  }
  
  void _handleSessionEndedConfirm(Map<String, dynamic> data) {
    try {
      final sessionId = data['session_id'] as String?;
      final finalData = data['finalData'];
      
      debugPrint('Session ended confirmation received for session: $sessionId');
      debugPrint('Final session data: $finalData');
      
      // Ensure all teacher state is properly reset
      isTeacherSessionActive.value = false;
      teacherActiveSessionId.value = null;
      onlineStudents.value = [];
      attendanceStatus.value = {};
      sessionStatistics.value = null;
      
      // Show confirmation notification to teacher
      _showLocalNotification(
        title: 'Session Ended Successfully',
        body: 'The attendance session has been terminated and data saved.',
      );
    } catch (e) {
      debugPrint('Error handling session ended confirmation: $e');
    }
  }
  
  void _handleAttendanceMarked(Map<String, dynamic> data) {
    try {
      final studentId = data['studentId'] as String?;
      final status = data['status'] as String?;
      final isCurrentUser = studentId == _currentUserId;
      
      if (isCurrentUser && status != null) {
        final message = _getAttendanceMessage(status);
        _showLocalNotification(
          title: 'Attendance Updated',
          body: message,
        );
      }
    } catch (e) {
      debugPrint('Error handling attendance marked: $e');
    }
  }
  
  void _handleStudentJoined(Map<String, dynamic> data) {
    try {
      // Handle studentJoinedAttendance event data structure
      final studentId = data['student_id'] as String?;
      final studentName = data['student_name'] as String?;
      final joinedAt = data['joined_at'] as String?;
      
      if (studentId != null) {
        final student = OnlineStudent(
          studentId: studentId,
          joinedAt: joinedAt != null ? DateTime.parse(joinedAt) : DateTime.now(),
          isOnline: true,
          student: studentName != null ? StudentInfo(
            id: studentId,
            name: studentName,
            email: '', // Not provided in the event
            profilePicture: null,
          ) : null,
        );
        
        final currentStudents = List<OnlineStudent>.from(onlineStudents.value);
        
        // Remove if already exists and add the new one
        currentStudents.removeWhere((s) => s.studentId == student.studentId);
        currentStudents.add(student);
        
        onlineStudents.value = currentStudents;
        debugPrint('Student ${studentName ?? studentId} joined the session');
      }
    } catch (e) {
      debugPrint('Error handling student joined: $e');
    }
  }
  
  void _handleStudentLeft(Map<String, dynamic> data) {
    try {
      final studentId = data['studentId'] as String?;
      if (studentId != null) {
        final currentStudents = List<OnlineStudent>.from(onlineStudents.value);
        currentStudents.removeWhere((s) => s.studentId == studentId);
        onlineStudents.value = currentStudents;
      }
    } catch (e) {
      debugPrint('Error handling student left: $e');
    }
  }
  
  void _handleAttendanceUpdated(Map<String, dynamic> data) {
    try {
      final studentId = data['studentId'] as String?;
      final status = data['status'] as String?;
      
      if (studentId != null && status != null) {
        final currentStatus = Map<String, String>.from(attendanceStatus.value);
        currentStatus[studentId] = status;
        attendanceStatus.value = currentStatus;
      }
      
      // Update statistics if provided
      if (data['statistics'] != null) {
        sessionStatistics.value = AttendanceStatistics.fromJson(data['statistics']);
      }
    } catch (e) {
      debugPrint('Error handling attendance updated: $e');
    }
  }
  
  void _handleOnlineStudentsUpdated(Map<String, dynamic> data) {
    try {
      final studentsData = data['students'] as List<dynamic>? ?? [];
      final students = studentsData
          .map((studentData) => OnlineStudent.fromJson(studentData))
          .toList();
      
      onlineStudents.value = students;
    } catch (e) {
      debugPrint('Error handling online students updated: $e');
    }
  }

  void _handleOnlineStudentsData(Map<String, dynamic> data) {
    try {
      final studentsData = data['online_students'] as List<dynamic>? ?? [];
      final students = studentsData.map((studentData) {
        // Handle roll field which can be int or String
        final rollValue = studentData['roll'];
        final rollString = rollValue?.toString();
        
        return OnlineStudent(
          studentId: studentData['student_id'] as String,
          joinedAt: DateTime.parse(studentData['joined_at'] as String),
          leftAt: null,
          isOnline: true,
          student: StudentInfo(
            id: studentData['student_id'] as String,
            name: studentData['student_name'] as String,
            email: studentData['email'] as String? ?? '',
            roll: rollString,
            profilePicture: studentData['profile_picture'] as String?,
          ),
        );
      }).toList();
      
      onlineStudents.value = students;
      debugPrint('Updated online students from server: ${students.length} students');
    } catch (e) {
      debugPrint('Error handling online students data: $e');
    }
  }
  
  void _handleAttendanceError(Map<String, dynamic> data) {
    final message = data['message'] as String? ?? 'An error occurred';
    errorMessage.value = message;
    
    _showLocalNotification(
      title: 'Attendance Error',
      body: message,
    );
  }

  void _handleStudentMarkedPresent(Map<String, dynamic> data) {
    try {
      final studentId = data['student_id'] as String?;
      final attendanceRecord = data['attendanceRecord'] as Map<String, dynamic>?;
      
      if (studentId != null) {
        // Update local attendance status
        final currentStatus = Map<String, String>.from(attendanceStatus.value);
        currentStatus[studentId] = 'present';
        attendanceStatus.value = currentStatus;
        
        debugPrint('Student $studentId marked as present');
      }
    } catch (e) {
      debugPrint('Error handling student marked present: $e');
    }
  }

  void _handleStudentMarkedAbsent(Map<String, dynamic> data) {
    try {
      final studentId = data['student_id'] as String?;
      final attendanceRecord = data['attendanceRecord'] as Map<String, dynamic>?;
      
      if (studentId != null) {
        // Update local attendance status
        final currentStatus = Map<String, String>.from(attendanceStatus.value);
        currentStatus[studentId] = 'absent';
        attendanceStatus.value = currentStatus;
        
        debugPrint('Student $studentId marked as absent');
      }
    } catch (e) {
      debugPrint('Error handling student marked absent: $e');
    }
  }
  
  // Helper Methods
  
  String _getAttendanceMessage(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return 'You have been marked present! ✅';
      case 'absent':
        return 'You have been marked absent ❌';
      case 'late':
        return 'You have been marked late ⏰';
      case 'excused':
        return 'You have been marked excused 📝';
      default:
        return 'Your attendance status has been updated';
    }
  }
  
  // Get attendance status for a student
  String getStudentAttendanceStatus(String studentId) {
    return attendanceStatus.value[studentId] ?? 'absent';
  }
  
  // Check if student is online
  bool isStudentOnline(String studentId) {
    return onlineStudents.value.any((student) => 
        student.studentId == studentId && student.isOnline);
  }
  
  // Get online student count
  int get onlineStudentCount => onlineStudents.value.length;
  
  // Get attendance statistics
  AttendanceStatistics? get currentStatistics => sessionStatistics.value;
  
  // Check if current user can join session
  bool get canJoinSession => 
      _currentUserRole == 'student' && 
      isSessionActive.value && 
      !hasJoinedSession.value &&
      isConnected.value;
  
  // Check if current user can start session
  bool get canStartSession => 
      _currentUserRole == 'teacher' && 
      !isTeacherSessionActive.value &&
      isConnected.value;
  
  // Reconnect socket
  Future<void> reconnect() async {
    try {
      isLoading.value = true;
      await _socketService.reconnect();
      isConnected.value = _socketService.isConnected;
      errorMessage.value = null;
    } catch (e) {
      errorMessage.value = 'Failed to reconnect: $e';
    } finally {
      isLoading.value = false;
    }
  }
  
  // Clear error message
  void clearError() {
    errorMessage.value = null;
  }
  
  // Show local notification helper
  Future<void> _showLocalNotification({required String title, required String body}) async {
    // For now, just print the notification. 
    // This should be implemented by adding a public method to NotificationService
    debugPrint('Attendance Notification: $title - $body');
    
    // TODO: Add a public showAttendanceNotification method to NotificationService
    // and call it here instead
  }
  
  // Dispose resources
  void dispose() {
    _socketService.removeAllListeners();
    _socketService.disconnect();
    
    // Dispose value notifiers
    isSessionActive.dispose();
    activeSessionId.dispose();
    activeCourseId.dispose();
    activeSessionTopic.dispose();
    hasJoinedSession.dispose();
    onlineStudents.dispose();
    attendanceStatus.dispose();
    isTeacherSessionActive.dispose();
    teacherActiveSessionId.dispose();
    sessionStatistics.dispose();
    isConnected.dispose();
    errorMessage.dispose();
    isLoading.dispose();
  }
}