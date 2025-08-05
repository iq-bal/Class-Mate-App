import 'package:flutter/material.dart';
import 'package:classmate/controllers/attendance/attendance_controller.dart';
import 'package:classmate/controllers/attendance/realtime_attendance_controller.dart';
import 'package:classmate/models/course_detail_teacher/enrollment_model.dart';
import 'package:classmate/models/attendance/attendance_session_model.dart';
import 'package:classmate/views/attendance/widgets/attendance_student_tile.dart';
import 'package:classmate/views/course_detail_teacher/widgets/custom_app_bar.dart';

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

class _AttendanceViewState extends State<AttendanceView> with SingleTickerProviderStateMixin {
  final AttendanceController _attendanceController = AttendanceController();
  final RealtimeAttendanceController _realtimeController = RealtimeAttendanceController();
  bool _isSessionActive = false;
  String? _currentSessionId;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchApprovedStudents();
    _initializeRealtimeController();
  }

  Future<void> _initializeRealtimeController() async {
    try {
      await _realtimeController.initialize();
      // Listen for session updates
      _realtimeController.isSessionActive.addListener(() {
        if (mounted) {
          setState(() {
            _isSessionActive = _realtimeController.isSessionActive.value;
            _currentSessionId = _realtimeController.activeSessionId.value;
          });
        }
      });
    } catch (e) {
      debugPrint('Failed to initialize realtime controller: $e');
    }
  }

  Future<void> _fetchApprovedStudents() async {
    await _attendanceController.fetchApprovedStudents(widget.courseId);
  }

  Future<void> _startAttendanceSession() async {
    try {
      final sessionId = await _attendanceController.startAttendanceSession(
        widget.courseId,
      );
      
      if (sessionId != null) {
        setState(() {
          _isSessionActive = true;
          _currentSessionId = sessionId;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Attendance session started! Session ID: $_currentSessionId'),
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

  Future<void> _endAttendanceSession() async {
    if (_currentSessionId == null) return;
    
    try {
      await _attendanceController.endAttendanceSession(_currentSessionId!);
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
      if (status == 'present') {
        await _realtimeController.markStudentPresent(studentId);
      } else {
        await _realtimeController.markStudentAbsent(studentId);
      }
      
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

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          // Session Control Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isSessionActive ? Colors.green.shade50 : Colors.grey.shade50,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      _isSessionActive ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      color: _isSessionActive ? Colors.green : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isSessionActive ? 'Session Active' : 'Session Inactive',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _isSessionActive ? Colors.green : Colors.grey,
                      ),
                    ),
                    const Spacer(),
                    if (_isSessionActive)
                      Text(
                        'Session ID: ${_currentSessionId?.substring(0, 8)}...',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSessionActive ? _endAttendanceSession : _startAttendanceSession,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isSessionActive ? Colors.red : Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      _isSessionActive ? 'End Session' : 'Start Attendance Session',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Tab Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              tabs: const [
                Tab(
                  icon: Icon(Icons.people),
                  text: 'All Students',
                ),
                Tab(
                  icon: Icon(Icons.wifi),
                  text: 'Online',
                ),
              ],
            ),
          ),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllStudentsTab(),
                _buildOnlineStudentsTab(),
              ],
            ),
          ),
        ],
      ),
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
              // Statistics Header
              Container(
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Students',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            '${approvedStudents.length}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Present',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            '${_attendanceController.presentCount}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Absent',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            '${_attendanceController.absentCount}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Students List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: approvedStudents.length,
                  itemBuilder: (context, index) {
                    final enrollment = approvedStudents[index];
                    return ValueListenableBuilder<List<OnlineStudent>>(
                      valueListenable: _realtimeController.onlineStudents,
                      builder: (context, onlineStudents, child) {
                        final isOnline = onlineStudents.any((online) => online.studentId == enrollment.student.id);
                        return AttendanceStudentTile(
                          enrollment: enrollment,
                          isSessionActive: _isSessionActive,
                          attendanceStatus: _realtimeController.getStudentAttendanceStatus(enrollment.student.id),
                          isOnline: isOnline,
                          onMarkPresent: () => _markAttendance(enrollment.student.id, 'present'),
                     onMarkAbsent: () => _markAttendance(enrollment.student.id, 'absent'),
                          onJoinSession: null, // Remove join session functionality
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

  Widget _buildOnlineStudentsTab() {
    // Request online students when tab is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _realtimeController.requestOnlineStudents();
    });
    
    return ValueListenableBuilder<List<OnlineStudent>>(
      valueListenable: _realtimeController.onlineStudents,
      builder: (context, onlineStudents, child) {
        if (onlineStudents.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.wifi_off,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No students online',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _realtimeController.requestOnlineStudents(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Online Statistics Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn('Online', onlineStudents.length.toString(), Colors.green),
                      _buildStatColumn('Present', onlineStudents.where((s) => _attendanceController.getStudentAttendanceStatus(s.studentId) == 'present').length.toString(), Colors.blue),
                      _buildStatColumn('Absent', onlineStudents.where((s) => _attendanceController.getStudentAttendanceStatus(s.studentId) == 'absent').length.toString(), Colors.red),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        onPressed: () => _realtimeController.requestOnlineStudents(),
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Refresh'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Online Students List
            Expanded(
              child: ListView.builder(
                itemCount: onlineStudents.length,
                itemBuilder: (context, index) {
                  final onlineStudent = onlineStudents[index];
                  
                  // Find corresponding enrollment
                   EnrollmentModel? enrollment;
                   try {
                     enrollment = _attendanceController.approvedStudents.firstWhere(
                       (e) => e.student.id == onlineStudent.studentId,
                     );
                   } catch (e) {
                     enrollment = null;
                   }
                   
                   if (enrollment == null) {
                     // Create a temporary enrollment-like structure for display
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
                             Text('ID: ${onlineStudent.studentId}'),
                             Text('Roll: ${onlineStudent.student?.roll ?? 'N/A'}'),
                             Row(
                               children: [
                                 const Icon(Icons.circle, size: 8, color: Colors.green),
                                 const SizedBox(width: 4),
                                 Text(
                                   'Online since ${_formatTime(onlineStudent.joinedAt)}',
                                   style: const TextStyle(fontSize: 12, color: Colors.green),
                                 ),
                               ],
                             ),
                           ],
                         ),
                         trailing: PopupMenuButton<String>(
                           onSelected: (status) => _markAttendance(onlineStudent.studentId, status),
                           itemBuilder: (context) => [
                             const PopupMenuItem(value: 'present', child: Text('Present')),
                             const PopupMenuItem(value: 'absent', child: Text('Absent')),
                             const PopupMenuItem(value: 'late', child: Text('Late')),
                           ],
                           child: Container(
                             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                             decoration: BoxDecoration(
                               color: _getStatusColor(_attendanceController.getStudentAttendanceStatus(onlineStudent.studentId) ?? 'absent'),
                               borderRadius: BorderRadius.circular(12),
                             ),
                             child: Text(
                               (_attendanceController.getStudentAttendanceStatus(onlineStudent.studentId) ?? 'absent').toUpperCase(),
                               style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                             ),
                           ),
                         ),
                       ),
                     );
                   } 
                  
                  return AttendanceStudentTile(
                    enrollment: enrollment!,
                    isSessionActive: _isSessionActive,
                    attendanceStatus: _realtimeController.getStudentAttendanceStatus(enrollment!.student.id),
                    isOnline: true,
                    onMarkPresent: () => _markAttendance(enrollment!.student.id, 'present'),
                     onMarkAbsent: () => _markAttendance(enrollment!.student.id, 'absent'),
                    onJoinSession: null,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }



  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _attendanceController.dispose();
    _realtimeController.dispose();
    super.dispose();
  }
}