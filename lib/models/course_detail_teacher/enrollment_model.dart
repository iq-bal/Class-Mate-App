class EnrollmentModel {
  final String id;
  final String status;
  final String enrolledAt;
  final StudentEnrollmentModel student;

  EnrollmentModel({
    required this.id,
    required this.status,
    required this.enrolledAt,
    required this.student,
  });

  factory EnrollmentModel.fromJson(Map<String, dynamic> json) {
    return EnrollmentModel(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      enrolledAt: json['enrolled_at']?.toString() ?? '',
      student: StudentEnrollmentModel.fromJson(json['student'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'enrolled_at': enrolledAt,
      'student': student.toJson(),
    };
  }
}

class StudentEnrollmentModel {
  final String id;
  final String roll;
  final String section;
  final String name;
  final String email;
  final String profilePicture;

  StudentEnrollmentModel({
    required this.id,
    required this.roll,
    required this.section,
    required this.name,
    required this.email,
    required this.profilePicture,
  });

  factory StudentEnrollmentModel.fromJson(Map<String, dynamic> json) {
    return StudentEnrollmentModel(
      id: json['id']?.toString() ?? '',
      roll: json['roll']?.toString() ?? '',
      section: json['section']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      profilePicture: json['profile_picture']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roll': roll,
      'section': section,
      'name': name,
      'email': email,
      'profile_picture': profilePicture,
    };
  }
}