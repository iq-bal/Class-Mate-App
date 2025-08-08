import 'package:flutter/material.dart';
import 'package:classmate/controllers/attendance/attendance_controller.dart';
import 'package:classmate/controllers/attendance/realtime_attendance_controller.dart';

import 'package:classmate/models/attendance/attendance_session_model.dart';
import 'package:classmate/views/attendance/widgets/attendance_student_tile.dart';
import 'package:classmate/views/course_detail_teacher/widgets/custom_app_bar.dart';
import 'package:classmate/views/attendance/widgets/session_input_bottom_sheet.dart';

class AttendanceView extends StatefulWidget {
  final String courseId;
  final String courseTitle;

  const AttendanceView({
    super.key,
    required this.courseId,
    required this.courseTitle,
  });

  @override
  State<AttendanceView> createState() => _AttendanceViewState();
}

class _AttendanceViewState extends State<AttendanceView> {
  final AttendanceController _attendanceController = AttendanceController();
  final RealtimeAttendanceController _realtimeController = RealtimeAttendanceController();

  bool _isSessionActive = false;
  String? _currentSessionId;

  @override
  void initState() {
    super.initState();
    _fetchApprovedStudents();
  }


  Future<void> _fetchApprovedStudents() async {
    await _attendanceController.fetchApprovedStudents(widget.courseId);
  }

  Future<void> _showSessionInputBottomSheet() async {
    final result = await showSessionInputBottomSheet(
      context: context,
      courseId: widget.courseId,
    );
    
    if (result != null) {
      await _startAttendanceSession(
        topic: result['topic'] as String,
        meetingLink: result['meetingLink'] as String?,
      );
    }
  }

  Future<void> _startAttendanceSession({
    required String topic,
    String? meetingLink,
  }) async {
    try {
      final sessionId = await _attendanceController.startAttendanceSession(
        widget.courseId,
        topic: topic,
        meetingLink: meetingLink,
      );
      
      if (sessionId != null) {
        setState(() {
          _isSessionActive = true;
          _currentSessionId = sessionId;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Attendance session "$topic" started!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start session: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _endAttendanceSession()  {
    if (_currentSessionId == null) return;
    try {
      _attendanceController.endAttendanceSession(_currentSessionId!);
      setState(() {
        _isSessionActive = false;
        _currentSessionId = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Attendance session ended successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to end session: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _markAttendance(String studentId, String status) async {
    try {
      if(_currentSessionId == null){
        throw Exception('No active session');
      }
      await _attendanceController.markAttendance(_currentSessionId!, studentId, status);
      // No success snackbar per requirement
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to mark attendance: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: CustomAppBar(
        title: 'Attendance - ${widget.courseTitle}',
        onBackPressed: () {
          Navigator.of(context).pop();
        },
        onMorePressed: () {
          // Additional options if needed
        },
      ),
      body: Column(
        children: [
          // Modern Session Control Header
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isSessionActive 
                    ? [Colors.green.shade400, Colors.green.shade600]
                    : [Colors.blue.shade400, Colors.blue.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: (_isSessionActive ? Colors.green : Colors.blue).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _isSessionActive ? Icons.play_circle_filled : Icons.pause_circle_filled,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isSessionActive ? 'Session Active' : 'Ready to Start',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_isSessionActive)
                            Text(
                              'ID: ${_currentSessionId?.substring(0, 8)}...',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSessionActive ? _endAttendanceSession : _showSessionInputBottomSheet,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: _isSessionActive ? Colors.red : Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isSessionActive ? Icons.stop : Icons.play_arrow,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isSessionActive ? 'End Session' : 'Start Attendance Session',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Students List
          Expanded(
            child: _buildStudentsSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsSection() {
    return ValueListenableBuilder<AttendanceState>(
      valueListenable: _attendanceController.stateNotifier,
      builder: (context, state, child) {
        if (state == AttendanceState.loading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state == AttendanceState.error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  _attendanceController.errorMessage ?? 'Error occurred',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _fetchApprovedStudents,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        } else if (state == AttendanceState.success) {
          final approvedStudents = _attendanceController.approvedStudents;
          
          if (approvedStudents.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No approved students found',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Modern Statistics Cards
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total',
                        '${approvedStudents.length}',
                        Icons.people,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Present',
                        '${_attendanceController.presentCount}',
                        Icons.check_circle,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Absent',
                        '${_attendanceController.absentCount}',
                        Icons.cancel,
                        Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Modern Students List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: approvedStudents.length,
                  itemBuilder: (context, index) {
                    final enrollment = approvedStudents[index];
                    return ValueListenableBuilder<List<OnlineStudent>>(
                      valueListenable: _realtimeController.onlineStudents,
                      builder: (context, onlineStudents, child) {
                        final isOnline = onlineStudents.any((online) => online.studentId == enrollment.student.id);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: AttendanceStudentTile(
                            enrollment: enrollment,
                            isSessionActive: _isSessionActive,
                            attendanceStatus: _attendanceController.getStudentAttendanceStatus(enrollment.student.id),
                            isOnline: isOnline,
                            onMarkPresent: () => _markAttendance(enrollment.student.id, 'present'),
                            onMarkAbsent: () => _markAttendance(enrollment.student.id, 'absent'),
                            onJoinSession: null,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        }
        return const Center(child: Text('No data available'));
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
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
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }





  @override
  void dispose() {
    _attendanceController.dispose();
    _realtimeController.dispose();
    super.dispose();
  }
}