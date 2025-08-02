class ProfileStudentModel {
  final String id;
  final String roll;
  final String section;
  final String name;
  final String email;
  final String? profilePicture;
  final String? about;
  final String department;
  final String semester;
  final String cgpa;
  final UserModel userId;
  final List<EnrollmentModel> enrollments;

  ProfileStudentModel({
    required this.id,
    required this.roll,
    required this.section,
    required this.name,
    required this.email,
    this.profilePicture,
    this.about,
    required this.department,
    required this.semester,
    required this.cgpa,
    required this.userId,
    required this.enrollments,
  });

  factory ProfileStudentModel.fromJson(Map<String, dynamic> json) {
    return ProfileStudentModel(
      id: json['id'] ?? '',
      roll: json['roll'] ?? '',
      section: json['section'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profilePicture: json['profile_picture'],
      about: json['about'],
      department: json['department'] ?? '',
      semester: json['semester'] ?? '',
      cgpa: json['cgpa'] ?? '',
      userId: UserModel.fromJson(json['user_id'] ?? {}),
      enrollments: (json['enrollments'] as List<dynamic>? ?? [])
          .map((enrollment) => EnrollmentModel.fromJson(enrollment))
          .toList(),
    );
  }
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? profilePicture;
  final String? coverPicture;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profilePicture,
    this.coverPicture,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profilePicture: json['profile_picture'],
      coverPicture: json['cover_picture'],
    );
  }
}

class EnrollmentModel {
  final String id;
  final String status;
  final String enrolledAt;
  final List<CourseModel> courses;

  EnrollmentModel({
    required this.id,
    required this.status,
    required this.enrolledAt,
    required this.courses,
  });

  factory EnrollmentModel.fromJson(Map<String, dynamic> json) {
    return EnrollmentModel(
      id: json['id'] ?? '',
      status: json['status'] ?? '',
      enrolledAt: json['enrolled_at'] ?? '',
      courses: (json['courses'] as List<dynamic>? ?? [])
          .map((course) => CourseModel.fromJson(course))
          .toList(),
    );
  }
}

class CourseModel {
  final String id;
  final String title;
  final String courseCode;
  final String? description;
  final String? image;
  final int credit;

  CourseModel({
    required this.id,
    required this.title,
    required this.courseCode,
    this.description,
    this.image,
    required this.credit,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      courseCode: json['course_code'] ?? '',
      description: json['description'],
      image: json['image'],
      credit: json['credit'] ?? 0,
    );
  }
}