import 'package:flutter/material.dart';
import 'package:classmate/controllers/attendance/realtime_attendance_controller.dart';
import 'package:classmate/models/attendance/attendance_session_model.dart';
// import 'package:classmate/widgets/custom_app_bar.dart'; // TODO: Create this widget
import 'package:classmate/views/home/widgets/attendance_session_card.dart';

class StudentAttendanceView extends StatefulWidget {
  final String courseId;
  final String courseTitle;

  const StudentAttendanceView({
    super.key,
    required this.courseId,
    required this.courseTitle,
  });

  @override
  State<StudentAttendanceView> createState() => _StudentAttendanceViewState();
}

class _StudentAttendanceViewState extends State<StudentAttendanceView> {
  late RealtimeAttendanceController _controller;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = RealtimeAttendanceController();
    _initializeController();
  }

  Future<void> _initializeController() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _controller.initialize();
      // Connect to course channel for session updates
      // TODO: Add method to listen for course sessions
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to initialize: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _joinSession() async {
    final sessionId = _controller.activeSessionId.value;
    if (sessionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No active session to join'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    try {
      await _controller.joinSession(sessionId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully joined the session!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to join session: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _leaveSession() async {
    try {
      await _controller.leaveSession();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Left the session'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to leave session: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.courseTitle),
            Text(
              'Attendance',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                // Session Card
                AttendanceSessionCard(
                  controller: _controller,
                  onJoinSession: _joinSession,
                  onLeaveSession: _leaveSession,
                ),
                
                // Session Details
                Expanded(
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _controller.isSessionActive,
                    builder: (context, isSessionActive, child) {
                      if (!isSessionActive) {
                        return _buildNoActiveSession();
                      }
                      
                      // For now, show basic session info
                      return _buildBasicSessionInfo();
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildNoActiveSession() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Active Session',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Wait for your teacher to start an attendance session',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBasicSessionInfo() {
    return ValueListenableBuilder<String?>(
      valueListenable: _controller.activeSessionId,
      builder: (context, sessionId, child) {
        return ValueListenableBuilder<String?>(
          valueListenable: _controller.activeSessionTopic,
          builder: (context, topic, child) {
            return _buildSessionDetails(sessionId, topic);
          },
        );
      },
    );
  }

  Widget _buildSessionDetails(String? sessionId, String? topic) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Session Info Card
          Card(
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
                        'Session Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Session ID', sessionId ?? 'Unknown'),
                  _buildInfoRow('Topic', topic ?? 'No topic specified'),
                  _buildInfoRow('Status', 'Active'),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Statistics Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.analytics_outlined,
                        color: Colors.green.shade600,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Session Statistics',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ValueListenableBuilder<List<OnlineStudent>>(
                    valueListenable: _controller.onlineStudents,
                    builder: (context, onlineStudents, child) {
                      return Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Online Students',
                              onlineStudents.length.toString(),
                              Colors.orange,
                              Icons.wifi,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildStatCard(
                              'Your Status',
                              _controller.hasJoinedSession.value ? 'Joined' : 'Not Joined',
                              _controller.hasJoinedSession.value ? Colors.green : Colors.grey,
                              _controller.hasJoinedSession.value ? Icons.check_circle : Icons.radio_button_unchecked,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Online Students Card
          ValueListenableBuilder<List<OnlineStudent>>(
            valueListenable: _controller.onlineStudents,
            builder: (context, onlineStudents, child) {
              if (onlineStudents.isEmpty) {
                return const SizedBox.shrink();
              }
              
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.wifi,
                            color: Colors.orange.shade600,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Students Online',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...onlineStudents.map(
                        (student) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.green.shade100,
                                child: Icon(
                                  Icons.person,
                                  size: 16,
                                  color: Colors.green.shade600,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      student.student?.name ?? 'Unknown',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      'Joined: ${_formatDateTime(student.joinedAt)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: student.isOnline
                                      ? Colors.green.shade100
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  student.isOnline ? 'Online' : 'Offline',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: student.isOnline
                                        ? Colors.green.shade700
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}