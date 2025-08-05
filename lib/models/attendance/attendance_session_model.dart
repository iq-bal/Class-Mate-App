class AttendanceSessionModel {
  final String id;
  final String courseId;
  final String topic;
  final DateTime date;
  final bool isActive;
  final String createdBy;
  final List<AttendanceRecord> attendanceRecords;
  final List<OnlineStudent> onlineStudents;
  final DateTime createdAt;
  final DateTime? endedAt;
  final int totalStudents;
  final AttendanceStatistics statistics;

  AttendanceSessionModel({
    required this.id,
    required this.courseId,
    required this.topic,
    required this.date,
    required this.isActive,
    required this.createdBy,
    required this.attendanceRecords,
    required this.onlineStudents,
    required this.createdAt,
    this.endedAt,
    required this.totalStudents,
    required this.statistics,
  });

  factory AttendanceSessionModel.fromJson(Map<String, dynamic> json) {
    return AttendanceSessionModel(
      id: json['id'] ?? json['_id'] ?? '',
      courseId: json['courseId'] ?? json['course_id'] ?? '',
      topic: json['topic'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      isActive: json['isActive'] ?? json['is_active'] ?? false,
      createdBy: json['createdBy'] ?? json['created_by'] ?? '',
      attendanceRecords: (json['attendanceRecords'] as List<dynamic>? ?? [])
          .map((record) => AttendanceRecord.fromJson(record))
          .toList(),
      onlineStudents: (json['onlineStudents'] as List<dynamic>? ?? [])
          .map((student) => OnlineStudent.fromJson(student))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] ?? json['created_at'] ?? DateTime.now().toIso8601String()),
      endedAt: json['endedAt'] != null || json['ended_at'] != null
          ? DateTime.parse(json['endedAt'] ?? json['ended_at'])
          : null,
      totalStudents: json['totalStudents'] ?? json['total_students'] ?? 0,
      statistics: AttendanceStatistics.fromJson(json['statistics'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'topic': topic,
      'date': date.toIso8601String(),
      'isActive': isActive,
      'createdBy': createdBy,
      'attendanceRecords': attendanceRecords.map((record) => record.toJson()).toList(),
      'onlineStudents': onlineStudents.map((student) => student.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
      'totalStudents': totalStudents,
      'statistics': statistics.toJson(),
    };
  }

  AttendanceSessionModel copyWith({
    String? id,
    String? courseId,
    String? topic,
    DateTime? date,
    bool? isActive,
    String? createdBy,
    List<AttendanceRecord>? attendanceRecords,
    List<OnlineStudent>? onlineStudents,
    DateTime? createdAt,
    DateTime? endedAt,
    int? totalStudents,
    AttendanceStatistics? statistics,
  }) {
    return AttendanceSessionModel(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      topic: topic ?? this.topic,
      date: date ?? this.date,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      attendanceRecords: attendanceRecords ?? this.attendanceRecords,
      onlineStudents: onlineStudents ?? this.onlineStudents,
      createdAt: createdAt ?? this.createdAt,
      endedAt: endedAt ?? this.endedAt,
      totalStudents: totalStudents ?? this.totalStudents,
      statistics: statistics ?? this.statistics,
    );
  }
}

class AttendanceRecord {
  final String id;
  final String sessionId;
  final String studentId;
  final String status; // present, absent, late, excused
  final String remarks;
  final DateTime markedAt;
  final String markedBy;
  final StudentInfo? student;

  AttendanceRecord({
    required this.id,
    required this.sessionId,
    required this.studentId,
    required this.status,
    required this.remarks,
    required this.markedAt,
    required this.markedBy,
    this.student,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] ?? json['_id'] ?? '',
      sessionId: json['sessionId'] ?? json['session_id'] ?? '',
      studentId: json['studentId'] ?? json['student_id'] ?? '',
      status: json['status'] ?? 'absent',
      remarks: json['remarks'] ?? '',
      markedAt: DateTime.parse(json['markedAt'] ?? json['marked_at'] ?? DateTime.now().toIso8601String()),
      markedBy: json['markedBy'] ?? json['marked_by'] ?? '',
      student: json['student'] != null ? StudentInfo.fromJson(json['student']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'studentId': studentId,
      'status': status,
      'remarks': remarks,
      'markedAt': markedAt.toIso8601String(),
      'markedBy': markedBy,
      'student': student?.toJson(),
    };
  }

  AttendanceRecord copyWith({
    String? id,
    String? sessionId,
    String? studentId,
    String? status,
    String? remarks,
    DateTime? markedAt,
    String? markedBy,
    StudentInfo? student,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      studentId: studentId ?? this.studentId,
      status: status ?? this.status,
      remarks: remarks ?? this.remarks,
      markedAt: markedAt ?? this.markedAt,
      markedBy: markedBy ?? this.markedBy,
      student: student ?? this.student,
    );
  }
}

class OnlineStudent {
  final String studentId;
  final DateTime joinedAt;
  final DateTime? leftAt;
  final bool isOnline;
  final StudentInfo? student;

  OnlineStudent({
    required this.studentId,
    required this.joinedAt,
    this.leftAt,
    required this.isOnline,
    this.student,
  });

  factory OnlineStudent.fromJson(Map<String, dynamic> json) {
    return OnlineStudent(
      studentId: json['studentId'] ?? json['student_id'] ?? '',
      joinedAt: DateTime.parse(json['joinedAt'] ?? json['joined_at'] ?? DateTime.now().toIso8601String()),
      leftAt: json['leftAt'] != null || json['left_at'] != null
          ? DateTime.parse(json['leftAt'] ?? json['left_at'])
          : null,
      isOnline: json['isOnline'] ?? json['is_online'] ?? false,
      student: json['student'] != null ? StudentInfo.fromJson(json['student']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'joinedAt': joinedAt.toIso8601String(),
      'leftAt': leftAt?.toIso8601String(),
      'isOnline': isOnline,
      'student': student?.toJson(),
    };
  }

  OnlineStudent copyWith({
    String? studentId,
    DateTime? joinedAt,
    DateTime? leftAt,
    bool? isOnline,
    StudentInfo? student,
  }) {
    return OnlineStudent(
      studentId: studentId ?? this.studentId,
      joinedAt: joinedAt ?? this.joinedAt,
      leftAt: leftAt ?? this.leftAt,
      isOnline: isOnline ?? this.isOnline,
      student: student ?? this.student,
    );
  }
}

class StudentInfo {
  final String id;
  final String name;
  final String email;
  final String? roll;
  final String? section;
  final String? profilePicture;

  StudentInfo({
    required this.id,
    required this.name,
    required this.email,
    this.roll,
    this.section,
    this.profilePicture,
  });

  factory StudentInfo.fromJson(Map<String, dynamic> json) {
    return StudentInfo(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      roll: json['roll'],
      section: json['section'],
      profilePicture: json['profilePicture'] ?? json['profile_picture'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'roll': roll,
      'section': section,
      'profilePicture': profilePicture,
    };
  }
}

class AttendanceStatistics {
  final int totalStudents;
  final int presentCount;
  final int absentCount;
  final int lateCount;
  final int excusedCount;
  final double attendanceRate;

  AttendanceStatistics({
    required this.totalStudents,
    required this.presentCount,
    required this.absentCount,
    required this.lateCount,
    required this.excusedCount,
    required this.attendanceRate,
  });

  factory AttendanceStatistics.fromJson(Map<String, dynamic> json) {
    return AttendanceStatistics(
      totalStudents: json['totalStudents'] ?? json['total_students'] ?? 0,
      presentCount: json['presentCount'] ?? json['present_count'] ?? 0,
      absentCount: json['absentCount'] ?? json['absent_count'] ?? 0,
      lateCount: json['lateCount'] ?? json['late_count'] ?? 0,
      excusedCount: json['excusedCount'] ?? json['excused_count'] ?? 0,
      attendanceRate: (json['attendanceRate'] ?? json['attendance_rate'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalStudents': totalStudents,
      'presentCount': presentCount,
      'absentCount': absentCount,
      'lateCount': lateCount,
      'excusedCount': excusedCount,
      'attendanceRate': attendanceRate,
    };
  }

  AttendanceStatistics copyWith({
    int? totalStudents,
    int? presentCount,
    int? absentCount,
    int? lateCount,
    int? excusedCount,
    double? attendanceRate,
  }) {
    return AttendanceStatistics(
      totalStudents: totalStudents ?? this.totalStudents,
      presentCount: presentCount ?? this.presentCount,
      absentCount: absentCount ?? this.absentCount,
      lateCount: lateCount ?? this.lateCount,
      excusedCount: excusedCount ?? this.excusedCount,
      attendanceRate: attendanceRate ?? this.attendanceRate,
    );
  }
}