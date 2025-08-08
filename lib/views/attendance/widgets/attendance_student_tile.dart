import 'package:flutter/material.dart';
import 'package:classmate/models/course_detail_teacher/enrollment_model.dart';
import 'package:classmate/config/app_config.dart';

class AttendanceStudentTile extends StatefulWidget {
  final EnrollmentModel enrollment;
  final bool isSessionActive;
  final String? attendanceStatus;
  final bool isOnline;
  final VoidCallback? onMarkPresent;
  final VoidCallback? onMarkAbsent;
  final VoidCallback? onJoinSession;

  const AttendanceStudentTile({
    super.key,
    required this.enrollment,
    required this.isSessionActive,
    this.attendanceStatus,
    this.isOnline = false,
    this.onMarkPresent,
    this.onMarkAbsent,
    this.onJoinSession,
  });

  @override
  State<AttendanceStudentTile> createState() => _AttendanceStudentTileState();
}

class _AttendanceStudentTileState extends State<AttendanceStudentTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  String? _previousAttendanceStatus;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(AttendanceStudentTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Trigger animation when attendance status changes
    if (widget.attendanceStatus != _previousAttendanceStatus && 
        widget.attendanceStatus != null) {
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
      _previousAttendanceStatus = widget.attendanceStatus;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final student = widget.enrollment.student;
    
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: widget.attendanceStatus == 'present' ? Colors.green : Colors.red,
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Student Info Row
              Row(
                children: [
                  // Profile Picture
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: student.profilePicture.isNotEmpty
                          ? Image.network(
                              '${AppConfig.baseUrl}${student.profilePicture}',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey.shade200,
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.grey.shade600,
                                    size: 30,
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: Colors.grey.shade200,
                              child: Icon(
                                Icons.person,
                                color: Colors.grey.shade600,
                                size: 30,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Student Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'Roll: ${student.roll}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Section: ${student.section}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          student.email,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Online Status and Attendance Status Indicators
                  Column(
                    children: [
                      // Online Status Indicator
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: widget.isOnline ? Colors.green : Colors.grey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              widget.isOnline ? Icons.circle : Icons.circle_outlined,
                              color: Colors.white,
                              size: 8,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.isOnline ? 'Online' : 'Offline',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Attendance Status Indicator
                       if (widget.attendanceStatus != null) ...[
                         const SizedBox(height: 4),
                         Container(
                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                           decoration: BoxDecoration(
                             color: widget.attendanceStatus == 'present' ? Colors.green : Colors.red,
                             borderRadius: BorderRadius.circular(12),
                             boxShadow: [
                               BoxShadow(
                                 color: (widget.attendanceStatus == 'present' ? Colors.green : Colors.red).withOpacity(0.3),
                                 blurRadius: 4,
                                 offset: const Offset(0, 2),
                               ),
                             ],
                           ),
                           child: Row(
                             mainAxisSize: MainAxisSize.min,
                             children: [
                               Icon(
                                 widget.attendanceStatus == 'present' ? Icons.check_circle : Icons.cancel,
                                 color: Colors.white,
                                 size: 12,
                               ),
                               const SizedBox(width: 4),
                               Text(
                                 widget.attendanceStatus == 'present' ? 'Present' : 'Absent',
                                 style: const TextStyle(
                                   color: Colors.white,
                                   fontSize: 12,
                                   fontWeight: FontWeight.w600,
                                 ),
                               ),
                             ],
                           ),
                         ),
                       ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Attendance Buttons
              if (widget.isSessionActive)
                Column(
                  children: [
                    // Teacher Attendance Buttons
                    if (widget.onMarkPresent != null && widget.onMarkAbsent != null)
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: widget.attendanceStatus == 'present' ? null : widget.onMarkPresent,
                              icon: Icon(
                                Icons.check_circle,
                                size: 18,
                                color: widget.attendanceStatus == 'present' ? Colors.white : Colors.green,
                              ),
                              label: const Text(
                                'Present',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: widget.attendanceStatus == 'present' ? Colors.green : Colors.green.shade50,
                                foregroundColor: widget.attendanceStatus == 'present' ? Colors.white : Colors.green,
                                elevation: widget.attendanceStatus == 'present' ? 2 : 0,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                    color: Colors.green,
                                    width: widget.attendanceStatus == 'present' ? 0 : 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: widget.attendanceStatus == 'absent' ? null : widget.onMarkAbsent,
                              icon: Icon(
                                Icons.cancel,
                                size: 18,
                                color: widget.attendanceStatus == 'absent' ? Colors.white : Colors.red,
                              ),
                              label: const Text(
                                'Absent',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: widget.attendanceStatus == 'absent' ? Colors.red : Colors.red.shade50,
                                foregroundColor: widget.attendanceStatus == 'absent' ? Colors.white : Colors.red,
                                elevation: widget.attendanceStatus == 'absent' ? 2 : 0,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                    color: Colors.red,
                                    width: widget.attendanceStatus == 'absent' ? 0 : 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    'Start session to mark attendance',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}