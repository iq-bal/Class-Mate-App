import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:classmate/config/app_config.dart';
import 'package:classmate/core/token_storage.dart';
import 'package:flutter/foundation.dart';

class RealtimeAttendanceService {
  IO.Socket? _attendanceSocket;
  final TokenStorage _tokenStorage = TokenStorage();
  bool _isConnected = false;
  
  // Singleton pattern
  static final RealtimeAttendanceService _instance = RealtimeAttendanceService._internal();
  factory RealtimeAttendanceService() => _instance;
  RealtimeAttendanceService._internal();
  
  // Getters
  bool get isConnected => _isConnected;
  IO.Socket? get socket => _attendanceSocket;
  
  // Initialize attendance socket connection
  Future<void> initializeAttendanceSocket() async {
    try {
      final token = await _tokenStorage.retrieveAccessToken();
      
      if (token == null) {
        throw Exception('No access token found');
      }
      
      await _connectAttendanceSocket(token);

    } catch (e) {
      debugPrint('Failed to initialize attendance socket: $e');
      rethrow;
    }
  }
  
  // Connect to attendance namespace
  Future<void> _connectAttendanceSocket(String token) async {
    try {
      _attendanceSocket = IO.io(
        AppConfig.socketBaseUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .setAuth({'token': token})
            .build(),
      );
      _setupEventListeners();
      print(_isConnected);
    } catch (e) {
      debugPrint('Failed to connect attendance socket: $e');
      rethrow;
    }
  }
  
  // Setup basic event listeners
  void _setupEventListeners() {
    _attendanceSocket?.onConnect((_) {
      _isConnected = true;
      debugPrint('Connected to attendance socket');
    });
    
    _attendanceSocket?.onDisconnect((_) {
      _isConnected = false;
      debugPrint('Disconnected from attendance socket');
    });
    
    _attendanceSocket?.onConnectError((data) {
      _isConnected = false;
      debugPrint('Attendance socket connection error: $data');
    });
    
    _attendanceSocket?.onError((data) {
      debugPrint('Attendance socket error: $data');
    });
  }
  
  // Student Methods
  
  // Join an attendance session
  void joinAttendanceSession(String sessionId, String studentId) {
    if (!_isConnected) {
      debugPrint('Socket not connected, cannot join session');
      return;
    }
    
    _attendanceSocket?.emit('joinAttendanceSession', {
      'sessionId': sessionId,
      'studentId': studentId,
    });
    
    debugPrint('Joining attendance session: $sessionId');
  }
  
  // Leave an attendance session
  void leaveAttendanceSession(String sessionId, String studentId) {
    if (!_isConnected) {
      debugPrint('Socket not connected, cannot leave session');
      return;
    }
    
    _attendanceSocket?.emit('leaveAttendanceSession', {
      'sessionId': sessionId,
      'studentId': studentId,
    });
    
    debugPrint('Leaving attendance session: $sessionId');
  }
  
  // Teacher Methods
  
  // Start an attendance session
  void startAttendanceSession(String sessionId) {
    if (!_isConnected) {
      debugPrint('Socket not connected, cannot start session');
      return;
    }
    _attendanceSocket?.emit('startAttendanceSession', {
      'session_id': sessionId,
    });    
    debugPrint('Starting attendance session for session: $sessionId');
  }
  
  // End an attendance session
  void endAttendanceSession(String sessionId) {
    if (!_isConnected) {
      debugPrint('Socket not connected, cannot end session');
      return;
    }
    
    _attendanceSocket?.emit('endAttendanceSession', {
      'session_id': sessionId,
    });
    debugPrint('Ending attendance session: $sessionId');
  }
  
  // Mark student attendance
  void markStudentAttendance(String sessionId, String studentId, String status, {String? remarks}) {
    if (!_isConnected) {
      debugPrint('Socket not connected, cannot mark attendance');
      return;
    }

    _attendanceSocket?.emit('markStudentAttendance', {
      'sessionId': sessionId,
      'studentId': studentId,
      'status': status,
      'remarks': remarks ?? '',
    });

    debugPrint('Marking attendance for student $studentId: $status');
  }

  // Mark student present (specific method based on give_attendance.md)
  void markStudentPresent(String sessionId, String studentId) {
    if (!_isConnected) {
      debugPrint('Socket not connected, cannot mark student present');
      return;
    }

    _attendanceSocket?.emit('markStudentPresent', {
      'session_id': sessionId,
      'student_id': studentId,
    });

    debugPrint('Marking student $studentId as present in session: $sessionId');
  }

  // Mark student absent (specific method based on give_attendance.md)
  void markStudentAbsent(String sessionId, String studentId) {
    if (!_isConnected) {
      debugPrint('Socket not connected, cannot mark student absent');
      return;
    }

    _attendanceSocket?.emit('markStudentAbsent', {
      'session_id': sessionId,
      'student_id': studentId,
    });

    debugPrint('Marking student $studentId as absent in session: $sessionId');
  }

  // Get online students for a session
  void getOnlineStudents(String sessionId) {
    if (!_isConnected) {
      debugPrint('Socket not connected, cannot get online students');
      return;
    }

    _attendanceSocket?.emit('getOnlineStudents', {
      'session_id': sessionId,
    });

    debugPrint('Requesting online students for session: $sessionId');
  }
  
  // Event Listeners
  
  // Listen for session started events
  void onAttendanceSessionStarted(Function(Map<String, dynamic>) callback) {
    _attendanceSocket?.on('attendanceSessionStarted', (data) {
      debugPrint('Attendance session started: $data');
      callback(Map<String, dynamic>.from(data));
    });
  }
  
  // Listen for session ended events
  void onAttendanceSessionEnded(Function(Map<String, dynamic>) callback) {
    _attendanceSocket?.on('attendanceSessionEnded', (data) {
      debugPrint('Attendance session ended: $data');
      callback(Map<String, dynamic>.from(data));
    });
  }
  
  // Listen for session ended confirmation events (teacher only)
  void onAttendanceSessionEndedConfirm(Function(Map<String, dynamic>) callback) {
    _attendanceSocket?.on('attendanceSessionEndedConfirm', (data) {
      debugPrint('Attendance session ended confirmation: $data');
      callback(Map<String, dynamic>.from(data));
    });
  }
  
  // Listen for student joined events
  void onStudentJoined(Function(Map<String, dynamic>) callback) {
    _attendanceSocket?.on('studentJoinedAttendance', (data) {
      debugPrint('Student joined attendance: $data');
      callback(Map<String, dynamic>.from(data));
    });
  }
  
  // Listen for student left events
  void onStudentLeft(Function(Map<String, dynamic>) callback) {
    _attendanceSocket?.on('studentLeft', (data) {
      debugPrint('Student left: $data');
      callback(Map<String, dynamic>.from(data));
    });
  }
  
  // Listen for attendance marked events
  void onAttendanceMarked(Function(Map<String, dynamic>) callback) {
    _attendanceSocket?.on('attendanceMarked', (data) {
      debugPrint('Attendance marked: $data');
      callback(Map<String, dynamic>.from(data));
    });
  }
  
  // Listen for attendance updated events
  void onAttendanceUpdated(Function(Map<String, dynamic>) callback) {
    _attendanceSocket?.on('attendanceUpdated', (data) {
      debugPrint('Attendance updated: $data');
      callback(Map<String, dynamic>.from(data));
    });
  }

  // Listen for student marked present events (teacher notification)
  void onStudentMarkedPresent(Function(Map<String, dynamic>) callback) {
    _attendanceSocket?.on('studentMarkedPresent', (data) {
      debugPrint('Student marked present: $data');
      callback(Map<String, dynamic>.from(data));
    });
  }

  // Listen for student marked absent events (teacher notification)
  void onStudentMarkedAbsent(Function(Map<String, dynamic>) callback) {
    _attendanceSocket?.on('studentMarkedAbsent', (data) {
      debugPrint('Student marked absent: $data');
      callback(Map<String, dynamic>.from(data));
    });
  }
  
  // Listen for online students updates
  void onOnlineStudentsUpdated(Function(Map<String, dynamic>) callback) {
    _attendanceSocket?.on('onlineStudentsUpdated', (data) {
      debugPrint('Online students updated: $data');
      callback(Map<String, dynamic>.from(data));
    });
  }

  // Listen for online students data response
  void onOnlineStudentsData(Function(Map<String, dynamic>) callback) {
    _attendanceSocket?.on('onlineStudentsData', (data) {
      debugPrint('Online students data received: $data');
      callback(Map<String, dynamic>.from(data));
    });
  }
  
  // Listen for errors
  void onAttendanceError(Function(Map<String, dynamic>) callback) {
    _attendanceSocket?.on('attendanceError', (data) {
      debugPrint('Attendance error: $data');
      callback(Map<String, dynamic>.from(data));
    });
  }
  
  // Remove all listeners
  void removeAllListeners() {
    _attendanceSocket?.clearListeners();
  }
  
  // Remove specific listener
  void removeListener(String event) {
    _attendanceSocket?.off(event);
  }
  
  // Disconnect socket
  void disconnect() {
    if (_attendanceSocket != null) {
      _attendanceSocket!.disconnect();
      _attendanceSocket = null;
      _isConnected = false;
      debugPrint('Attendance socket disconnected');
    }
  }
  
  // Reconnect socket
  Future<void> reconnect() async {
    disconnect();
    await initializeAttendanceSocket();
  }
  
  // Check if socket is connected and ready
  bool isReady() {
    return _attendanceSocket != null && _isConnected;
  }
}