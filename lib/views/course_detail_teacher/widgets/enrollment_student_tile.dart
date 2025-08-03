import 'package:classmate/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:classmate/models/course_detail_teacher/enrollment_model.dart';

class EnrollmentStudentTile extends StatelessWidget {
  final EnrollmentModel enrollment;
  final VoidCallback? onTap;
  final Function(String enrollmentId, String status)? onStatusUpdate;

  const EnrollmentStudentTile({
    super.key,
    required this.enrollment,
    this.onTap,
    this.onStatusUpdate,
  });

  Color _getStatusColor() {
    switch (enrollment.status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (enrollment.status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle;
      case 'pending':
        return Icons.access_time;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 2,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: Colors.grey[300],
          backgroundImage: enrollment.student.profilePicture.isNotEmpty
              ? NetworkImage('${AppConfig.imageServer}$enrollment.student.profilePicture')
              : null,
          child: enrollment.student.profilePicture.isEmpty
              ? const Icon(Icons.person, color: Colors.grey)
              : null,
        ),
        title: Text(
          enrollment.student.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Roll: ${enrollment.student.roll}'),
            Text('Section: ${enrollment.student.section}'),
            Text('Email: ${enrollment.student.email}'),
            const SizedBox(height: 4),
            Text(
              'Enrolled: ${_formatDate(enrollment.enrolledAt)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: enrollment.status.toLowerCase() == 'pending' && onStatusUpdate != null
            ? _buildStatusDropdown()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getStatusIcon(),
                    color: _getStatusColor(),
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    enrollment.status.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
        isThreeLine: true,
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildStatusDropdown() {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              'PENDING',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
            SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              color: Colors.orange,
              size: 16,
            ),
          ],
        ),
      ),
      onSelected: (String status) {
        if (onStatusUpdate != null) {
          onStatusUpdate!(enrollment.id, status);
        }
      },
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem<String>(
          value: 'approved',
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Text('Approve'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'rejected',
          child: Row(
            children: [
              Icon(Icons.cancel, color: Colors.red, size: 20),
              SizedBox(width: 8),
              Text('Reject'),
            ],
          ),
        ),
      ],
    );
  }
}