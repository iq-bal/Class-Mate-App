class TeacherDashboardModel {
  final UserModel user;

  TeacherDashboardModel({
    required this.user,
  });

  factory TeacherDashboardModel.fromJson(Map<String, dynamic> json) {
    return TeacherDashboardModel(
      user: UserModel.fromJson(json['user'] ?? {}),
    );
  }
}

class UserModel {
  final List<CourseModel> courses;

  UserModel({
    required this.courses,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      courses: (json['courses'] as List? ?? [])
          .map((course) => CourseModel.fromJson(course))
          .toList(),
    );
  }
}

class CourseModel {
  final String id;
  final String title;
  final String courseCode;
  final String description;
  final int credit;
  final String excerpt;
  final String? image;
  final String createdAt;
  final int enrolled;

  CourseModel({
    required this.id,
    required this.title,
    required this.courseCode,
    required this.description,
    required this.credit,
    required this.excerpt,
    this.image,
    required this.createdAt,
    required this.enrolled,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      courseCode: json['course_code']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      credit: json['credit'] ?? 0,
      excerpt: json['excerpt']?.toString() ?? '',
      image: json['image']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
      enrolled: json['enrolled'] ?? 0,
    );
  }
}