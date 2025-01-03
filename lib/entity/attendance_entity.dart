class AttendanceEntity {
  final String? id;
  final String? sessionId;
  final String? studentId;
  final String? status;
  final String? remarks;
  final DateTime? createdAt;

  const AttendanceEntity({
    this.id,
    this.sessionId,
    this.studentId,
    this.status,
    this.remarks,
    this.createdAt,
  });

  // Factory method to create an AttendanceEntity from JSON
  factory AttendanceEntity.fromJson(Map<String, dynamic> json) {
    return AttendanceEntity(
      id: json['id'] as String?,
      sessionId: json['session_id'] as String?,
      studentId: json['student_id'] as String?,
      status: json['status'] as String?,
      remarks: json['remarks'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
    );
  }

  // Method to convert an AttendanceEntity to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_id': sessionId,
      'student_id': studentId,
      'status': status,
      'remarks': remarks,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}