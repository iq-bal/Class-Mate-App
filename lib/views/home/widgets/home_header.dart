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

class _HomeHeaderState extends State<HomeHeader> with SingleTickerProviderStateMixin {
  // Using TickerProvider from State for animations
  IO.Socket? _socket;
  Timer? _reconnectTimer;
  Timer? _sessionCheckTimer;
  bool _hasActiveSession = false;
  final TokenStorage _tokenStorage = TokenStorage();

  late final AnimationController _liveBlinkController;
  late final Animation<double> _liveBlinkScale;

  @override
  void initState() {
    super.initState();
    _liveBlinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _liveBlinkScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _liveBlinkController, curve: Curves.easeInOut),
    );
    _initializeSocket();
  }

  @override
  void didUpdateWidget(HomeHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.courseId != widget.courseId) {
      if (oldWidget.courseId != null) {
        _socket?.emit('unsubscribeFromCourse', {
          'course_id': oldWidget.courseId,
        });
      }
      _subscribeToCourse();
    }
  }

  @override
  void dispose() {
    _reconnectTimer?.cancel();
    _sessionCheckTimer?.cancel();
    _unsubscribeFromCourse();
    _socket?.disconnect();
    _liveBlinkController.dispose();
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
        });
        print('📊 Live state from current sessions - hasActiveSession: $_hasActiveSession');
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
          });
          print('📊 Live state updated - hasActiveSession: $_hasActiveSession');
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
          _hasActiveSession = false;
        });
      }
    });

    // Remove join listeners; not needed in live-indicator-only UI
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
      _sessionCheckTimer?.cancel();
      _sessionCheckTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
        if (widget.courseId != null && _socket?.connected == true) {
          print('🔄 Periodic session check for course: ${widget.courseId}');
          _socket?.emit('getActiveSessions', {'course_id': widget.courseId});
        }
      });
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


  // Join flow removed; we only indicate live status visually

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

          // Current Class + Live indicator (no join button)
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: _hasActiveSession
                        ? LinearGradient(
                            colors: [Colors.green.shade400, Colors.green.shade600],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: _hasActiveSession ? null : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: _hasActiveSession
                        ? [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_hasActiveSession)
                        ScaleTransition(
                          scale: _liveBlinkScale,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      else ...[
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        _hasActiveSession ? 'Online' : 'Offline',
                        style: TextStyle(
                          color: _hasActiveSession ? Colors.white : Colors.grey,
                          fontWeight: FontWeight.bold,
                          letterSpacing: _hasActiveSession ? 1.0 : 0.2,
                        ),
                      ),
                    ],
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
