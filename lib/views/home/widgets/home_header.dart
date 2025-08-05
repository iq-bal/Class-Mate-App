import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:classmate/config/app_config.dart';
import 'package:classmate/core/token_storage.dart';

class HomeHeader extends StatefulWidget {
  final String userName;
  final String currentClass;
  final String currentInstructor;
  final String? courseId;
  final VoidCallback onNotificationTap;

  const HomeHeader({
    super.key,
    required this.userName,
    required this.currentClass,
    required this.currentInstructor,
    this.courseId,
    required this.onNotificationTap,
  });

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  IO.Socket? _socket;
  Timer? _reconnectTimer;
  Timer? _sessionCheckTimer;
  bool _isJoinButtonEnabled = false;
  bool _hasActiveSession = false;
  String? _currentSessionId;
  final TokenStorage _tokenStorage = TokenStorage();

  @override
  void initState() {
    super.initState();
    _initializeSocket();
  }

  @override
  void dispose() {
    _reconnectTimer?.cancel();
    _sessionCheckTimer?.cancel();
    _unsubscribeFromCourse();
    _socket?.disconnect();
    super.dispose();
  }

  Future<void> _initializeSocket() async {
    try {
      final token = await _tokenStorage.retrieveAccessToken();
      if (token != null) {
        _connectSocket(token);
      }
    } catch (e) {
      print('Failed to initialize socket: $e');
    }
  }

  void _connectSocket(String token) {
    _socket = IO.io(
      AppConfig.socketBaseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );

    _socket?.onConnect((_) {
      print('✅ Connected to Socket.IO server');
      print('🔗 Socket ID: ${_socket?.id}');
      // Add a small delay to ensure connection is fully established
      Future.delayed(const Duration(milliseconds: 100), () {
        _subscribeToCourse();
      });
    });

    _socket?.onConnectError((data) {
      print('Connection error: $data');
    });

    _socket?.onDisconnect((_) {
      print('Disconnected from Socket.IO server');
    });

    // Listen for subscription confirmation
    _socket?.on('subscriptionConfirmed', (data) {
      print('✅ Subscription confirmed: $data');
    });

    _socket?.on('subscriptionError', (data) {
      print('❌ Subscription error: $data');
    });

    // Listen for immediate active sessions response
    _socket?.on('currentActiveSessions', (data) {
      print('📊 Current active sessions response: $data');
      if (mounted && data['course_id'] == widget.courseId) {
        // Check if there's a direct session_id in the response
        final directSessionId = data['session_id'] as String?;
        final activeSessions = data['activeSessions'] as List? ?? [];
        
        print('📊 Direct session_id: $directSessionId');
        print('📊 Found ${activeSessions.length} current active sessions for course ${widget.courseId}');
        
        // Debug: Print the structure of the first session
        if (activeSessions.isNotEmpty) {
          print('📊 First session structure: ${activeSessions.first}');
          print('📊 Available keys: ${activeSessions.first.keys}');
        }
        
        setState(() {
          _hasActiveSession = directSessionId != null || activeSessions.isNotEmpty;
          _isJoinButtonEnabled = directSessionId != null || activeSessions.isNotEmpty;
          
          if (directSessionId != null) {
               // Use direct session ID from response
               _currentSessionId = directSessionId;
             } else if (activeSessions.isNotEmpty) {
               // Extract sessionId from activeSessions array (camelCase as per data structure)
               _currentSessionId = activeSessions.first['sessionId'] ?? 
                                 activeSessions.first['session_id'] ?? 
                                 activeSessions.first['_id'] ?? 
                                 activeSessions.first['id'];
          } else {
            _currentSessionId = null;
          }
        });
        
        print('📊 Button state from current sessions - hasActiveSession: $_hasActiveSession, isEnabled: $_isJoinButtonEnabled, sessionId: $_currentSessionId');
      }
    });

    // Listen for real-time session events
    _socket?.on('courseSessionStarted', (data) {
      print('🟢 New session started! $data');
      print('🟢 Event received for course: ${data['course_id']}');
      print('🟢 Current widget courseId: ${widget.courseId}');
      if (mounted && data['course_id'] == widget.courseId) {
        setState(() {
          _hasActiveSession = true;
          _isJoinButtonEnabled = true;
          _currentSessionId = data['session_id'];
        });
        // Show notification that session started
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('📢 Attendance session started by ${data['teacher_name'] ?? 'Teacher'}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });

    _socket?.on('courseSessionEnded', (data) {
      print('🔴 Session ended! $data');
      if (mounted && data['course_id'] == widget.courseId) {
        setState(() {
          _hasActiveSession = false;
          _isJoinButtonEnabled = false;
          _currentSessionId = null;
        });
        // Show notification that session ended
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Session ended. ${data['message'] ?? 'Attendance session has ended'}'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });

    // Get current active sessions (sent immediately + on changes)
    _socket?.on('activeSessionsData', (data) {
      print('📊 Active sessions: $data');
      print('📊 Course ID from data: ${data['course_id']}');
      print('📊 Widget Course ID: ${widget.courseId}');
      print('📊 Active sessions list: ${data['activeSessions']}');
      
      if (mounted) {
        // Check if this data is for the current course
        if (data['course_id'] == widget.courseId) {
          // Check if there's a direct session_id in the response
          final directSessionId = data['session_id'] as String?;
          final activeSessions = data['activeSessions'] as List? ?? [];
          
          print('📊 Direct session_id: $directSessionId');
          print('📊 Processing active sessions for current course: ${activeSessions.length} sessions');
          
          // Debug: Print the structure of the first session
          if (activeSessions.isNotEmpty) {
            print('📊 First session structure: ${activeSessions.first}');
            print('📊 Available keys: ${activeSessions.first.keys}');
          }
          
          setState(() {
            _hasActiveSession = directSessionId != null || activeSessions.isNotEmpty;
            _isJoinButtonEnabled = directSessionId != null || activeSessions.isNotEmpty;
            
            if (directSessionId != null) {
               // Use direct session ID from response
               _currentSessionId = directSessionId;
             } else if (activeSessions.isNotEmpty) {
               // Extract sessionId from activeSessions array (camelCase as per data structure)
               _currentSessionId = activeSessions.first['sessionId'] ?? 
                                 activeSessions.first['session_id'] ?? 
                                 activeSessions.first['_id'] ?? 
                                 activeSessions.first['id'];
            } else {
              _currentSessionId = null;
            }
          });
          
          print('📊 Button state updated - hasActiveSession: $_hasActiveSession, isEnabled: $_isJoinButtonEnabled, sessionId: $_currentSessionId');
        } else {
          print('📊 Ignoring data for different course: ${data['course_id']} vs ${widget.courseId}');
        }
      }
    });

    // Handle errors
    _socket?.on('activeSessionsError', (error) {
      print('Active sessions error: ${error['message']}');
      if (mounted) {
        setState(() {
          _isJoinButtonEnabled = false;
          _hasActiveSession = false;
        });
      }
    });

    // Listen for attendance session join responses
    _socket?.on('attendanceSessionJoined', (data) {
      print('✅ Successfully joined attendance session: ${data['session_id']}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Successfully joined attendance session'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });

    _socket?.on('attendanceError', (error) {
      print('❌ Failed to join attendance session: ${error['message']}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to join session: ${error['message']}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
  }

  void _subscribeToCourse() {
    if (widget.courseId != null && _socket?.connected == true) {
      print('📡 Attempting to subscribe to course: ${widget.courseId}');
      print('📡 Socket connected: ${_socket?.connected}');
      _socket?.emit('subscribeToCourse', {
        'course_id': widget.courseId,
      });
      print('📡 Subscription request sent for course: ${widget.courseId}');
      
      // Also request current active sessions immediately
      _socket?.emit('getActiveSessions', {'course_id': widget.courseId});
      print('📡 Requested current active sessions for course: ${widget.courseId}');
      
      // Start periodic session check as fallback
      _startSessionCheck();
    } else {
      print('❌ Cannot subscribe - courseId: ${widget.courseId}, socket connected: ${_socket?.connected}');
    }
  }

  void _unsubscribeFromCourse() {
    if (widget.courseId != null && _socket?.connected == true) {
      _socket?.emit('unsubscribeFromCourse', {
        'course_id': widget.courseId,
      });
      print('Unsubscribed from course: ${widget.courseId}');
    }
  }

  void _startSessionCheck() {
    _sessionCheckTimer?.cancel();
    _sessionCheckTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (widget.courseId != null && _socket?.connected == true) {
        print('🔄 Periodic session check for course: ${widget.courseId}');
        _socket?.emit('getActiveSessions', {'course_id': widget.courseId});
      }
    });
  }

  void _joinAttendanceSession() {
    if (_currentSessionId != null && _socket?.connected == true) {
      print('🚀 Joining attendance session: $_currentSessionId');
      _socket?.emit('joinAttendanceSession', {
        'session_id': _currentSessionId,
      });
    } else {
      print('❌ Cannot join session - sessionId: $_currentSessionId, socket connected: ${_socket?.connected}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Unable to join session. Please try again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  void didUpdateWidget(HomeHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.courseId != widget.courseId) {
      // Unsubscribe from old course and subscribe to new one
      if (oldWidget.courseId != null) {
        _socket?.emit('unsubscribeFromCourse', {
          'course_id': oldWidget.courseId,
        });
      }
      _subscribeToCourse();
    }
  }

  List<DateTime> _generateWeekDates() {
    final today = DateTime.now();
    return List.generate(7, (index) => today.add(Duration(days: index)));
  }

  String _generateGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Ready for your morning classes?";
    if (hour < 17) return "All set for the afternoon sessions?";
    return "Prepared for your evening studies?";
  }

  @override
  Widget build(BuildContext context) {
    final weekDates = _generateWeekDates();
    final today = DateTime.now();
    final subtitle = _generateGreetingMessage();

    return Container(
      decoration: BoxDecoration(
        color: Colors.blue[900],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        left: 20,
        right: 20,
        bottom: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting and Bell
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hello, ${widget.userName}!",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Georgia',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      fontFamily: 'Arial',
                    ),
                  ),
                ],
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue[800],
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: widget.onNotificationTap,
                  icon: const Icon(
                    Icons.notifications_none,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Dynamic Date Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: weekDates.map((date) {
              final isToday = date.day == today.day &&
                  date.month == today.month &&
                  date.year == today.year;

              return Column(
                children: [
                  CircleAvatar(
                    backgroundColor: isToday ? Colors.green : Colors.white,
                    radius: 18,
                    child: Text(
                      DateFormat.d().format(date), // e.g. 12
                      style: TextStyle(
                        color: isToday ? Colors.white : Colors.blue[900],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat.E().format(date), // e.g. Mon
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Current Class
          Container(
            decoration: BoxDecoration(
              color: Colors.yellow[100],
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.currentClass,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.currentInstructor,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: _isJoinButtonEnabled ? () {
                    print('🚀 Join button pressed - courseId: ${widget.courseId}');
                    _joinAttendanceSession();
                  } : () {
                    print('❌ Join button pressed but disabled - hasActiveSession: $_hasActiveSession');
                    // Show a message to user about why button is disabled
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No active attendance session found. Please wait for teacher to start the session.'),
                        backgroundColor: Colors.orange,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isJoinButtonEnabled ? Colors.blue[900] : Colors.grey[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Text(
                    _hasActiveSession ? "Join Session" : "No Active Session",
                    style: TextStyle(
                      fontSize: 14, 
                      color: _isJoinButtonEnabled ? Colors.white : Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
