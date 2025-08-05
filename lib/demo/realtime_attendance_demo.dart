import 'package:flutter/material.dart';
import 'package:classmate/controllers/attendance/realtime_attendance_controller.dart';
import 'package:classmate/views/attendance/realtime_attendance_view.dart';
import 'package:classmate/views/attendance/student_attendance_view.dart';
import 'package:classmate/views/home/widgets/attendance_session_card.dart';

class RealtimeAttendanceDemo extends StatefulWidget {
  const RealtimeAttendanceDemo({super.key});

  @override
  State<RealtimeAttendanceDemo> createState() => _RealtimeAttendanceDemoState();
}

class _RealtimeAttendanceDemoState extends State<RealtimeAttendanceDemo> {
  int _selectedIndex = 0;
  late RealtimeAttendanceController _controller;

  final String _demoTeacherId = 'teacher_123';
  final String _demoStudentId = 'student_456';
  final String _demoCourseId = 'course_789';
  final String _demoCourseTitle = 'Computer Science 101';

  @override
  void initState() {
    super.initState();
    _controller = RealtimeAttendanceController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Real-time Attendance Demo'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildTeacherView(),
          _buildStudentView(),
          _buildStudentHomeView(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Teacher View',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Student View',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Student Home',
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherView() {
    return RealtimeAttendanceView(
      courseId: _demoCourseId,
      courseTitle: _demoCourseTitle,
    );
  }

  Widget _buildStudentView() {
    return StudentAttendanceView(
      courseId: _demoCourseId,
      courseTitle: _demoCourseTitle,
    );
  }

  Widget _buildStudentHomeView() {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                Icon(
                  Icons.home,
                  color: Colors.blue.shade600,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Student Dashboard',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    Text(
                      'Welcome back!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Attendance Session Card
                  AttendanceSessionCard(
                    controller: _controller,
                    onJoinSession: () async {
                      final sessionId = _controller.activeSessionId.value;
                      if (sessionId != null) {
                        await _controller.joinSession(sessionId);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Joined session successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      }
                    },
                    onLeaveSession: () async {
                      await _controller.leaveSession();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Left session'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    },
                  ),
                  
                  // Demo Controls
                  Card(
                    margin: const EdgeInsets.all(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.settings,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Demo Controls',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Use these controls to simulate real-time attendance events:',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => _simulateSessionStart(),
                                icon: const Icon(Icons.play_arrow),
                                label: const Text('Start Session'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () => _simulateSessionEnd(),
                                icon: const Icon(Icons.stop),
                                label: const Text('End Session'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () => _simulateStudentJoin(),
                                icon: const Icon(Icons.person_add),
                                label: const Text('Student Join'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () => _simulateAttendanceUpdate(),
                                icon: const Icon(Icons.check),
                                label: const Text('Mark Present'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Connection Status
                  Card(
                    margin: const EdgeInsets.all(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.blue.shade600,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Connection Status',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ValueListenableBuilder<bool>(
                            valueListenable: _controller.isConnected,
                            builder: (context, isConnected, child) {
                              return Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: isConnected ? Colors.green : Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isConnected ? 'Connected to server' : 'Disconnected',
                                    style: TextStyle(
                                      color: isConnected ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          ValueListenableBuilder<String?>(
                            valueListenable: _controller.errorMessage,
                            builder: (context, errorMessage, child) {
                              if (errorMessage == null) {
                                return const SizedBox.shrink();
                              }
                              return Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Colors.red.shade200,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: Colors.red.shade600,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        errorMessage,
                                        style: TextStyle(
                                          color: Colors.red.shade700,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _simulateSessionStart() {
    // Call the actual startSession method with required parameters
    _controller.startSession(
      courseId: _demoCourseId,
      topic: 'Introduction to Algorithms',
      meetingLink: 'https://zoom.us/j/123456789',
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Creating session and starting with Socket.IO...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _simulateSessionEnd() {
    // Simulate session ended event
    _controller.isSessionActive.value = false;
    _controller.activeSessionId.value = null;
    _controller.activeCourseId.value = null;
    _controller.activeSessionTopic.value = null;
    _controller.hasJoinedSession.value = false;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Session ended.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _simulateStudentJoin() {
    if (!_controller.isSessionActive.value) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No active session to join'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    _controller.hasJoinedSession.value = true;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Successfully joined the session!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _simulateAttendanceUpdate() {
    if (!_controller.hasJoinedSession.value) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Join a session first to mark attendance'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Attendance marked as Present!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}