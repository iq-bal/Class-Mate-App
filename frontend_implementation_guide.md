# Frontend Implementation Guide for Real-Time Attendance

## Overview
This guide outlines the specific changes needed in the Flutter app to implement real-time attendance functionality.

## Required Dependencies

Add to `pubspec.yaml`:
```yaml
dependencies:
  socket_io_client: ^2.0.3+1
  flutter_local_notifications: ^16.3.2 # If not already added
```

## File Structure Changes

```
lib/
├── services/
│   ├── socket_services.dart (enhance existing)
│   ├── realtime_attendance_service.dart (new)
│   └── notification_service.dart (enhance existing)
├── controllers/
│   └── attendance/
│       ├── attendance_controller.dart (enhance existing)
│       └── realtime_attendance_controller.dart (new)
├── models/
│   └── attendance/
│       ├── attendance_session_model.dart (new)
│       └── online_student_model.dart (new)
└── views/
    ├── home/home_view.dart (modify join button logic)
    ├── attendance/attendance_view.dart (add real-time features)
    └── class_details_student/class_details_student_view.dart (add real-time updates)
```

## Implementation Steps

### Step 1: Enhance Socket Service

**File: `lib/services/socket_services.dart`**

Add attendance-specific socket functionality:

```dart
class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _mainSocket;
  IO.Socket? _attendanceSocket;
  
  // Add attendance socket initialization
  Future<void> initAttendanceSocket() async {
    final token = await TokenStorage.getToken();
    
    _attendanceSocket = IO.io('${AppConfig.baseUrl}/attendance', {
      'transports': ['websocket'],
      'auth': {'token': token},
      'autoConnect': true,
    });
    
    _attendanceSocket?.connect();
  }
  
  // Student methods
  void joinAttendanceSession(String sessionId, String studentId) {
    _attendanceSocket?.emit('joinAttendanceSession', {
      'sessionId': sessionId,
      'studentId': studentId,
    });
  }
  
  void leaveAttendanceSession(String sessionId, String studentId) {
    _attendanceSocket?.emit('leaveAttendanceSession', {
      'sessionId': sessionId,
      'studentId': studentId,
    });
  }
  
  // Teacher methods
  void startAttendanceSession(String courseId, String topic) {
    _attendanceSocket?.emit('startAttendanceSession', {
      'courseId': courseId,
      'topic': topic,
    });
  }
  
  void markStudentAttendance(String sessionId, String studentId, String status) {
    _attendanceSocket?.emit('markStudentAttendance', {
      'sessionId': sessionId,
      'studentId': studentId,
      'status': status,
    });
  }
  
  void endAttendanceSession(String sessionId) {
    _attendanceSocket?.emit('endAttendanceSession', {
      'sessionId': sessionId,
    });
  }
  
  // Event listeners
  void onAttendanceSessionStarted(Function(dynamic) callback) {
    _attendanceSocket?.on('attendanceSessionStarted', callback);
  }
  
  void onStudentJoined(Function(dynamic) callback) {
    _attendanceSocket?.on('studentJoined', callback);
  }
  
  void onAttendanceMarked(Function(dynamic) callback) {
    _attendanceSocket?.on('attendanceMarked', callback);
  }
  
  void onAttendanceUpdated(Function(dynamic) callback) {
    _attendanceSocket?.on('attendanceUpdated', callback);
  }
  
  void onAttendanceSessionEnded(Function(dynamic) callback) {
    _attendanceSocket?.on('attendanceSessionEnded', callback);
  }
  
  void dispose() {
    _attendanceSocket?.disconnect();
    _attendanceSocket?.dispose();
  }
}
```

### Step 2: Create Real-Time Attendance Controller

**File: `lib/controllers/attendance/realtime_attendance_controller.dart`**

```dart
class RealtimeAttendanceController {
  final SocketService _socketService = SocketService();
  final NotificationService _notificationService = NotificationService();
  
  // Student state
  final ValueNotifier<bool> isSessionActive = ValueNotifier(false);
  final ValueNotifier<String?> activeSessionId = ValueNotifier(null);
  final ValueNotifier<String?> activeCourseId = ValueNotifier(null);
  
  // Teacher state
  final ValueNotifier<List<OnlineStudent>> onlineStudents = ValueNotifier([]);
  final ValueNotifier<Map<String, String>> attendanceStatus = ValueNotifier({});
  final ValueNotifier<bool> isTeacherSessionActive = ValueNotifier(false);
  
  void initialize() {
    _socketService.initAttendanceSocket();
    _setupEventListeners();
  }
  
  void _setupEventListeners() {
    // Student events
    _socketService.onAttendanceSessionStarted((data) {
      isSessionActive.value = true;
      activeSessionId.value = data['sessionId'];
      activeCourseId.value = data['courseId'];
      
      _notificationService.showAttendanceNotification(
        'Class session started! Tap to join.',
        type: 'session_started'
      );
    });
    
    _socketService.onAttendanceMarked((data) {
      final status = data['status'];
      _notificationService.showAttendanceNotification(
        status == 'present' 
            ? 'You have been marked present! ✅'
            : 'You have been marked absent ❌',
        type: 'attendance_marked'
      );
    });
    
    _socketService.onAttendanceSessionEnded((data) {
      isSessionActive.value = false;
      activeSessionId.value = null;
      activeCourseId.value = null;
      
      _notificationService.showAttendanceNotification(
        'Attendance session has ended.',
        type: 'session_ended'
      );
    });
    
    // Teacher events
    _socketService.onStudentJoined((data) {
      final currentList = List<OnlineStudent>.from(onlineStudents.value);
      currentList.add(OnlineStudent.fromJson(data));
      onlineStudents.value = currentList;
    });
    
    _socketService.onAttendanceUpdated((data) {
      final currentStatus = Map<String, String>.from(attendanceStatus.value);
      currentStatus[data['studentId']] = data['status'];
      attendanceStatus.value = currentStatus;
    });
  }
  
  // Student methods
  void joinSession(String sessionId, String studentId) {
    _socketService.joinAttendanceSession(sessionId, studentId);
  }
  
  void leaveSession(String sessionId, String studentId) {
    _socketService.leaveAttendanceSession(sessionId, studentId);
  }
  
  // Teacher methods
  Future<void> startSession({
  required String courseId,
  required String topic,
  String? meetingLink,
}) async {
    _socketService.startAttendanceSession(courseId, topic);
    isTeacherSessionActive.value = true;
  }
  
  void markAttendance(String sessionId, String studentId, String status) {
    _socketService.markStudentAttendance(sessionId, studentId, status);
  }
  
  void endSession(String sessionId) {
    _socketService.endAttendanceSession(sessionId);
    isTeacherSessionActive.value = false;
    onlineStudents.value = [];
    attendanceStatus.value = {};
  }
  
  void dispose() {
    isSessionActive.dispose();
    activeSessionId.dispose();
    activeCourseId.dispose();
    onlineStudents.dispose();
    attendanceStatus.dispose();
    isTeacherSessionActive.dispose();
  }
}
```

### Step 3: Enhance Home View

**File: `lib/views/home/home_view.dart`**

Modify the join button logic:

```dart
class _HomeViewState extends State<HomeView> {
  final HomeController _homeController = HomeController();
  final RealtimeAttendanceController _realtimeController = RealtimeAttendanceController();
  
  @override
  void initState() {
    super.initState();
    _realtimeController.initialize();
    _fetchHomeData();
  }
  
  Widget _buildJoinButton() {
    return ValueListenableBuilder<bool>(
      valueListenable: _realtimeController.isSessionActive,
      builder: (context, isActive, child) {
        if (!isActive) return const SizedBox.shrink();
        
        return ValueListenableBuilder<String?>(
          valueListenable: _realtimeController.activeCourseId,
          builder: (context, courseId, child) {
            // Check if the active session is for a course the student is enrolled in
            final isEnrolledInActiveCourse = _homeController.isStudentEnrolledInCourse(courseId);
            
            if (!isEnrolledInActiveCourse) return const SizedBox.shrink();
            
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ElevatedButton(
                onPressed: () => _joinAttendanceSession(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.video_call),
                    const SizedBox(width: 8),
                    const Text('Join Live Class', style: TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
  
  void _joinAttendanceSession() {
    final sessionId = _realtimeController.activeSessionId.value;
    final studentId = _homeController.user?.id;
    
    if (sessionId != null && studentId != null) {
      _realtimeController.joinSession(sessionId, studentId);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Joined attendance session'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
```

### Step 4: Enhance Attendance View (Teacher)

**File: `lib/views/attendance/attendance_view.dart`**

Add real-time features:

```dart
class _AttendanceViewState extends State<AttendanceView> {
  final AttendanceController _attendanceController = AttendanceController();
  final RealtimeAttendanceController _realtimeController = RealtimeAttendanceController();
  
  @override
  void initState() {
    super.initState();
    _realtimeController.initialize();
    _fetchApprovedStudents();
  }
  
  void _startAttendanceSession() async {
    try {
      // Start via GraphQL
      final sessionId = await _attendanceController.startAttendanceSession(widget.courseId);
      
      if (sessionId != null) {
        // Start real-time session
        await _realtimeController.startSession(
  courseId: widget.courseId,
  topic: 'Live Class Session',
);
        
        setState(() {
          _isSessionActive = true;
          _sessionId = sessionId;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Attendance session started successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to start session: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  void _markAttendance(String studentId, String status) async {
    if (_sessionId != null) {
      try {
        // Mark via GraphQL
        await _attendanceController.markAttendance(_sessionId!, studentId, status);
        
        // Update real-time
        _realtimeController.markAttendance(_sessionId!, studentId, status);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Student marked as $status'),
            backgroundColor: status == 'present' ? Colors.green : Colors.red,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark attendance: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Widget _buildOnlineStudentsSection() {
    return ValueListenableBuilder<List<OnlineStudent>>(
      valueListenable: _realtimeController.onlineStudents,
      builder: (context, onlineStudents, child) {
        if (onlineStudents.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: const Text(
              'No students online',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Online Students (${onlineStudents.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: onlineStudents.map((student) {
                  return Chip(
                    avatar: const CircleAvatar(
                      backgroundColor: Colors.green,
                      radius: 6,
                    ),
                    label: Text(student.name),
                    backgroundColor: Colors.green.shade100,
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

### Step 5: Enhance Class Details Student View

**File: `lib/views/class_details_student/class_details_student_view.dart`**

Add real-time attendance updates:

```dart
class _ClassDetailsStudentState extends State<ClassDetailsStudent> {
  final ClassDetailsStudentController _controller = ClassDetailsStudentController();
  final RealtimeAttendanceController _realtimeController = RealtimeAttendanceController();
  
  @override
  void initState() {
    super.initState();
    _realtimeController.initialize();
    _fetchClassDetails();
    _setupRealtimeListeners();
  }
  
  void _setupRealtimeListeners() {
    // Listen for attendance updates
    _realtimeController.isSessionActive.addListener(() {
      if (mounted) setState(() {});
    });
    
    // Listen for attendance marked events
    _realtimeController._socketService.onAttendanceMarked((data) {
      // Refresh attendance data
      _fetchClassDetails();
    });
    
    // Listen for session ended events
    _realtimeController._socketService.onAttendanceSessionEnded((data) {
      // Refresh attendance data
      _fetchClassDetails();
    });
  }
  
  Widget _buildAttendanceSection(dynamic details) {
    return Column(
      children: [
        AttendanceSummary(
          attendancePercentage: details.attendanceList.isEmpty
              ? 0.0
              : details.attendanceList
                  .where((e) => e.status?.toLowerCase() == "present")
                  .length /
                  details.attendanceList.length,
          presenceIndicators: details.attendanceList
              .map((e) => e.status?.toLowerCase() == "present" ? true : false)
              .toList(),
          feedbackText: HelperFunction.getAttendanceFeedback(
            details.attendanceList.isEmpty
                ? 0.0
                : details.attendanceList
                    .where((e) => e.status?.toLowerCase() == "present")
                    .length /
                    details.attendanceList.length,
          ),
        ),
        
        // Real-time session indicator
        ValueListenableBuilder<bool>(
          valueListenable: _realtimeController.isSessionActive,
          builder: (context, isActive, child) {
            if (!isActive) return const SizedBox.shrink();
            
            return Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Live attendance session active',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
```

### Step 6: Create Models

**File: `lib/models/attendance/online_student_model.dart`**

```dart
class OnlineStudent {
  final String studentId;
  final String name;
  final bool isOnline;
  final DateTime joinedAt;
  
  OnlineStudent({
    required this.studentId,
    required this.name,
    required this.isOnline,
    required this.joinedAt,
  });
  
  factory OnlineStudent.fromJson(Map<String, dynamic> json) {
    return OnlineStudent(
      studentId: json['studentId'],
      name: json['name'],
      isOnline: json['isOnline'] ?? true,
      joinedAt: DateTime.parse(json['joinedAt']),
    );
  }
}
```

**File: `lib/models/attendance/attendance_session_model.dart`**

```dart
class AttendanceSession {
  final String id;
  final String courseId;
  final String topic;
  final DateTime date;
  final bool isActive;
  final List<OnlineStudent> studentsOnline;
  
  AttendanceSession({
    required this.id,
    required this.courseId,
    required this.topic,
    required this.date,
    required this.isActive,
    required this.studentsOnline,
  });
  
  factory AttendanceSession.fromJson(Map<String, dynamic> json) {
    return AttendanceSession(
      id: json['_id'],
      courseId: json['courseId'],
      topic: json['topic'] ?? '',
      date: DateTime.parse(json['date']),
      isActive: json['isActive'],
      studentsOnline: (json['studentsOnline'] as List)
          .map((e) => OnlineStudent.fromJson(e))
          .toList(),
    );
  }
}
```

## Testing Checklist

- [ ] Socket connection establishes successfully
- [ ] Student receives notification when session starts
- [ ] Join button appears for enrolled students
- [ ] Teacher sees students joining in real-time
- [ ] Attendance marking updates in real-time
- [ ] Student receives attendance notification
- [ ] Session ending updates all participants
- [ ] Attendance percentage updates correctly
- [ ] Offline/online status works properly
- [ ] Error handling for network issues

## Notes

1. **Error Handling**: Add proper error handling for socket disconnections
2. **Reconnection**: Implement automatic reconnection logic
3. **Performance**: Consider using debouncing for rapid attendance updates
4. **Security**: Ensure all socket events are properly authenticated
5. **Testing**: Test with multiple students and teachers simultaneously

This implementation provides a complete real-time attendance system that meets all the specified requirements.