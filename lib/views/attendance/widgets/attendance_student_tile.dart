import 'package:flutter/material.dart';
import 'package:classmate/models/course_detail_teacher/enrollment_model.dart';
import 'package:classmate/config/app_config.dart';

class AttendanceStudentTile extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final student = enrollment.student;
    
    return Container(
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
        border: attendanceStatus != null
            ? Border.all(
                color: attendanceStatus == 'present' ? Colors.green : Colors.red,
                width: 2,
              )
            : null,
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
                    child: student.profilePicture != null && student.profilePicture!.isNotEmpty
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
                        color: isOnline ? Colors.green : Colors.grey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isOnline ? Icons.circle : Icons.circle_outlined,
                            color: Colors.white,
                            size: 8,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isOnline ? 'Online' : 'Offline',
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
                     if (attendanceStatus != null) ...[
                       const SizedBox(height: 4),
                       Container(
                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                         decoration: BoxDecoration(
                           color: attendanceStatus == 'present' ? Colors.green : Colors.red,
                           borderRadius: BorderRadius.circular(12),
                         ),
                         child: Text(
                           attendanceStatus == 'present' ? 'Present' : 'Absent',
                           style: const TextStyle(
                             color: Colors.white,
                             fontSize: 12,
                             fontWeight: FontWeight.w600,
                           ),
                         ),
                       ),
                     ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Attendance Buttons
            if (isSessionActive)
              Column(
                children: [

                  // Teacher Attendance Buttons
                  if (onMarkPresent != null && onMarkAbsent != null)
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: attendanceStatus == 'present' ? null : onMarkPresent,
                            icon: Icon(
                              Icons.check_circle,
                              size: 18,
                              color: attendanceStatus == 'present' ? Colors.white : Colors.green,
                            ),
                            label: const Text(
                              'Present',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: attendanceStatus == 'present' ? Colors.green : Colors.green.shade50,
                              foregroundColor: attendanceStatus == 'present' ? Colors.white : Colors.green,
                              elevation: attendanceStatus == 'present' ? 2 : 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: Colors.green,
                                  width: attendanceStatus == 'present' ? 0 : 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: attendanceStatus == 'absent' ? null : onMarkAbsent,
                            icon: Icon(
                              Icons.cancel,
                              size: 18,
                              color: attendanceStatus == 'absent' ? Colors.white : Colors.red,
                            ),
                            label: const Text(
                              'Absent',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: attendanceStatus == 'absent' ? Colors.red : Colors.red.shade50,
                              foregroundColor: attendanceStatus == 'absent' ? Colors.white : Colors.red,
                              elevation: attendanceStatus == 'absent' ? 2 : 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: Colors.red,
                                  width: attendanceStatus == 'absent' ? 0 : 1,
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
    );
  }
}