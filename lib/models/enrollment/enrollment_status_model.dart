import 'package:intl/intl.dart';

class EnrollmentStatusModel {
  final String id;
  final String status;
  final String enrolledAt;
  final String formattedDate;

  EnrollmentStatusModel({
    required this.id,
    required this.status,
    required this.enrolledAt,
  }) : formattedDate = _formatDate(enrolledAt);

  static String _formatDate(String dateString) {
    if (dateString.isEmpty) return '';
    try {
      DateTime date;
      // Check if the dateString is a Unix timestamp (all digits)
      if (RegExp(r'^\d+$').hasMatch(dateString)) {
        // Convert timestamp to DateTime
        final timestamp = int.parse(dateString);
        date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      } else {
        // Parse as ISO date string
        date = DateTime.parse(dateString);
      }
      return DateFormat('MMM d, yyyy').format(date);
    } catch (e) {
      return dateString; // Return original if parsing fails
    }
  }

  factory EnrollmentStatusModel.fromJson(Map<String, dynamic> json) {
    return EnrollmentStatusModel(
      id: json['id'] as String? ?? '',
      status: json['status'] as String? ?? '',
      enrolledAt: json['enrolled_at'] as String? ?? '',
    );
  }
}