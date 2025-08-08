import 'package:flutter/material.dart';
import 'package:classmate/controllers/attendance/attendance_controller.dart';
import 'package:classmate/controllers/attendance/realtime_attendance_controller.dart';
import 'package:classmate/models/course_detail_teacher/enrollment_model.dart';
import 'package:classmate/models/attendance/attendance_session_model.dart';
import 'package:classmate/views/attendance/widgets/attendance_student_tile.dart';
import 'package:classmate/views/course_detail_teacher/widgets/custom_app_bar.dart';

class RealtimeAttendanceView extends StatefulWidget {
  final String courseId;
  final String courseTitle;

  const RealtimeAttendanceView({
    super.key,
    required this.courseId,
    required this.courseTitle,
  });

  @override
  State<RealtimeAttendanceView> createState() => _RealtimeAttendanceViewState();
}

class _RealtimeAttendanceViewState extends State<RealtimeAttendanceView>
    with TickerProviderStateMixin {
  final AttendanceController _attendanceController = AttendanceController();
  final RealtimeAttendanceController _realtimeController = RealtimeAttendanceController();
  late TabController _tabController;
  
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _meetingLinkController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay(hour: DateTime.now().hour + 1, minute: DateTime.now().minute);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeControllers();
  }

  Future<void> _initializeControllers() async {
    await _realtimeController.initialize();
    _attendanceController.fetchApprovedStudents(widget.courseId);
  }

  void _startAttendanceSession() async {
    if (_topicController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a topic for the session'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // Start real-time session (this will create the session via GraphQL and start Socket.IO)
      await _realtimeController.startSession(
        courseId: widget.courseId,
        topic: _topicController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? 'Attendance session for ${_topicController.text.trim()}' 
            : _descriptionController.text.trim(),
        date: _selectedDate,
        startTime: _startTime,
        endTime: _endTime,
        meetingLink: _meetingLinkController.text.trim().isEmpty 
            ? null 
            : _meetingLinkController.text.trim(),
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Real-time attendance session started successfully'),
          backgroundColor: Colors.green,
        ),
      );
      
      _topicController.clear();
      _descriptionController.clear();
      _meetingLinkController.clear();
      _selectedDate = DateTime.now();
      _startTime = TimeOfDay.now();
      _endTime = TimeOfDay(hour: DateTime.now().hour + 1, minute: DateTime.now().minute);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to start session: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _endAttendanceSession() async {
    try {
      // End real-time session
      await _realtimeController.endSession();
      
      // End GraphQL session if there's an active session ID
      final sessionId = _realtimeController.teacherActiveSessionId.value;
      if (sessionId != null) {
        _attendanceController.endAttendanceSession(sessionId);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Attendance session ended'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to end session: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _markAttendance(String studentId, String status) async {
    try {
      await _realtimeController.markAttendance(studentId, status);
      
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

  void _showStartSessionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Attendance Session'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _topicController,
                decoration: const InputDecoration(
                  labelText: 'Session Title *',
                  hintText: 'e.g., Introduction to Data Structures',
                  border: OutlineInputBorder(),
                ),
                maxLength: 100,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Brief description of the session',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                maxLength: 200,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() {
                            _selectedDate = date;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: _startTime,
                        );
                        if (time != null) {
                          setState(() {
                            _startTime = time;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Start Time',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(_startTime.format(context)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: _endTime,
                        );
                        if (time != null) {
                          setState(() {
                            _endTime = time;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'End Time',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(_endTime.format(context)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _meetingLinkController,
                decoration: const InputDecoration(
                  labelText: 'Meeting Link (Optional)',
                  hintText: 'https://zoom.us/j/123456789',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startAttendanceSession();
            },
            child: const Text('Start Session'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Real-time Attendance - ${widget.courseTitle}',
        onBackPressed: () => Navigator.of(context).pop(),
        onMorePressed: () {},
      ),
      body: Column(
        children: [
          // Connection Status
          ValueListenableBuilder<bool>(
            valueListenable: _realtimeController.isConnected,
            builder: (context, isConnected, child) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: isConnected ? Colors.green.shade100 : Colors.red.shade100,
                child: Row(
                  children: [
                    Icon(
                      isConnected ? Icons.wifi : Icons.wifi_off,
                      size: 16,
                      color: isConnected ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isConnected ? 'Connected' : 'Disconnected',
                      style: TextStyle(
                        fontSize: 12,
                        color: isConnected ? Colors.green.shade800 : Colors.red.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (!isConnected) ...[
                      const Spacer(),
                      TextButton(
                        onPressed: _realtimeController.reconnect,
                        child: const Text('Reconnect', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
          
          // Session Control Header
          ValueListenableBuilder<bool>(
            valueListenable: _realtimeController.isTeacherSessionActive,
            builder: (context, isSessionActive, child) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSessionActive ? Colors.green.shade50 : Colors.grey.shade50,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          isSessionActive ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                          color: isSessionActive ? Colors.green : Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isSessionActive ? 'Session Active' : 'Session Inactive',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isSessionActive ? Colors.green : Colors.grey,
                          ),
                        ),
                        const Spacer(),
                        if (isSessionActive)
                          ValueListenableBuilder<String?>(
                            valueListenable: _realtimeController.activeSessionTopic,
                            builder: (context, topic, child) {
                              return Text(
                                topic ?? 'No topic',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontStyle: FontStyle.italic,
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSessionActive ? _endAttendanceSession : _showStartSessionDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSessionActive ? Colors.red : Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          isSessionActive ? 'End Session' : 'Start Real-time Session',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          // Tab Bar
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.people),
                    const SizedBox(width: 8),
                    const Text('Online Students'),
                    const SizedBox(width: 4),
                    ValueListenableBuilder<List<OnlineStudent>>(
                      valueListenable: _realtimeController.onlineStudents,
                      builder: (context, onlineStudents, child) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${onlineStudents.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.list),
                    SizedBox(width: 8),
                    Text('All Students'),
                  ],
                ),
              ),
            ],
          ),
          
          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Online Students Tab
                _buildOnlineStudentsTab(),
                // All Students Tab
                _buildAllStudentsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnlineStudentsTab() {
    return ValueListenableBuilder<List<OnlineStudent>>(
      valueListenable: _realtimeController.onlineStudents,
      builder: (context, onlineStudents, child) {
        if (onlineStudents.isEmpty) {
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
                  'No students online',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Students will appear here when they join the session',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Statistics
            ValueListenableBuilder<AttendanceStatistics?>(
              valueListenable: _realtimeController.sessionStatistics,
              builder: (context, statistics, child) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Online',
                          '${onlineStudents.length}',
                          Colors.blue,
                        ),
                      ),
                      Expanded(
                        child: _buildStatCard(
                          'Present',
                          '${statistics?.presentCount ?? 0}',
                          Colors.green,
                        ),
                      ),
                      Expanded(
                        child: _buildStatCard(
                          'Absent',
                          '${statistics?.absentCount ?? 0}',
                          Colors.red,
                        ),
                      ),
                      Expanded(
                        child: _buildStatCard(
                          'Late',
                          '${statistics?.lateCount ?? 0}',
                          Colors.orange,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            // Online Students List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: onlineStudents.length,
                itemBuilder: (context, index) {
                  final onlineStudent = onlineStudents[index];
                  return _buildOnlineStudentTile(
                    onlineStudent: onlineStudent,
                    attendanceStatus: _realtimeController.getStudentAttendanceStatus(onlineStudent.studentId),
                    onMarkAttendance: (status) => _markAttendance(onlineStudent.studentId, status),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAllStudentsTab() {
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
                  onPressed: () => _attendanceController.fetchApprovedStudents(widget.courseId),
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

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: approvedStudents.length,
            itemBuilder: (context, index) {
              final enrollment = approvedStudents[index];
              final isOnline = _realtimeController.isStudentOnline(enrollment.student.id);
              
              return ValueListenableBuilder<bool>(
                valueListenable: _realtimeController.isTeacherSessionActive,
                builder: (context, isSessionActive, child) {
                  return AttendanceStudentTile(
                    enrollment: enrollment,
                    isSessionActive: isSessionActive,
                    attendanceStatus: _realtimeController.getStudentAttendanceStatus(enrollment.student.id),
                    onMarkPresent: () => _markAttendance(enrollment.student.id, 'present'),
                    onMarkAbsent: () => _markAttendance(enrollment.student.id, 'absent'),
                  );
                },
              );
            },
          );
        }
        return const Center(child: Text('No data available'));
      },
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildOnlineStudentTile({
    required OnlineStudent onlineStudent,
    required String attendanceStatus,
    required Function(String) onMarkAttendance,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
           backgroundColor: Colors.green,
           child: Text(
             (onlineStudent.student?.name ?? 'U').substring(0, 1).toUpperCase(),
             style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
           ),
         ),
         title: Text(
           onlineStudent.student?.name ?? 'Unknown Student',
           style: const TextStyle(fontWeight: FontWeight.w600),
         ),
         subtitle: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Text('ID: ${onlineStudent.student?.id ?? onlineStudent.studentId}'),
            Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 8,
                  color: onlineStudent.isOnline ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  onlineStudent.isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 12,
                    color: onlineStudent.isOnline ? Colors.green : Colors.grey,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Joined: ${_formatTime(onlineStudent.joinedAt)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(attendanceStatus),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                attendanceStatus.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: onMarkAttendance,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'present',
                  child: Row(
                    children: [
                      Icon(Icons.check, color: Colors.green, size: 16),
                      SizedBox(width: 8),
                      Text('Present'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'absent',
                  child: Row(
                    children: [
                      Icon(Icons.close, color: Colors.red, size: 16),
                      SizedBox(width: 8),
                      Text('Absent'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'late',
                  child: Row(
                    children: [
                      Icon(Icons.schedule, color: Colors.orange, size: 16),
                      SizedBox(width: 8),
                      Text('Late'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'excused',
                  child: Row(
                    children: [
                      Icon(Icons.event_note, color: Colors.blue, size: 16),
                      SizedBox(width: 8),
                      Text('Excused'),
                    ],
                  ),
                ),
              ],
              child: const Icon(Icons.more_vert),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return Colors.green;
      case 'absent':
        return Colors.red;
      case 'late':
        return Colors.orange;
      case 'excused':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _topicController.dispose();
    _descriptionController.dispose();
    _meetingLinkController.dispose();
    _attendanceController.dispose();
    _realtimeController.dispose();
    super.dispose();
  }
}