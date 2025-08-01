class HomePageModel {
  final UserHomeModel user;
  final List<EnrollmentHomeModel> enrollments;

  HomePageModel({
    required this.user,
    required this.enrollments,
  });

  factory HomePageModel.fromJson(Map<String, dynamic> json) {
    return HomePageModel(
      user: UserHomeModel.fromJson(json['user'] ?? {}),
      enrollments: (json['enrollments'] as List? ?? [])
          .map((enrollment) => EnrollmentHomeModel.fromJson(enrollment))
          .toList(),
    );
  }
}

class ScheduleHomeModel {
  final String id;
  final String day;
  final String startTime;
  final String endTime;
  final String roomNumber;
  final String section;

  ScheduleHomeModel({
    required this.id,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.roomNumber,
    required this.section,
  });

  factory ScheduleHomeModel.fromJson(Map<String, dynamic> json) {
    return ScheduleHomeModel(
      id: json['id']?.toString() ?? '',
      day: json['day']?.toString() ?? '',
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
      roomNumber: json['room_number']?.toString() ?? '',
      section: json['section']?.toString() ?? '',
    );
  }
}

class EnrollmentHomeModel {
  final String id;
  final String status;
  final String enrolledAt;
  final List<CourseHomeModel> courses;

  EnrollmentHomeModel({
    required this.id,
    required this.status,
    required this.enrolledAt,
    required this.courses,
  });

  factory EnrollmentHomeModel.fromJson(Map<String, dynamic> json) {
    return EnrollmentHomeModel(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      enrolledAt: json['enrolled_at']?.toString() ?? '',
      courses: (json['courses'] as List? ?? [])
          .map((course) => CourseHomeModel.fromJson(course))
          .toList(),
    );
  }
}

class CourseHomeModel {
  final String id;
  final String title;
  final String courseCode;
  final String description;
  final String image;
  final int credit;
  final TeacherHomeModel teacher;
  final List<AssignmentHomeModel> assignments;
  final List<ClassTestHomeModel> classTests;
  final List<ScheduleHomeModel> schedules;

  CourseHomeModel({
    required this.id,
    required this.title,
    required this.courseCode,
    required this.description,
    required this.image,
    required this.credit,
    required this.teacher,
    required this.assignments,
    required this.classTests,
    required this.schedules,
  });

  factory CourseHomeModel.fromJson(Map<String, dynamic> json) {
    return CourseHomeModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      courseCode: json['course_code']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      credit: json['credit'] ?? 0,
      teacher: TeacherHomeModel.fromJson(json['teacher'] ?? {}),
      assignments: (json['assignments'] as List? ?? [])
          .map((assignment) => AssignmentHomeModel.fromJson(assignment))
          .toList(),
      classTests: (json['classTests'] as List? ?? [])
          .map((classTest) => ClassTestHomeModel.fromJson(classTest))
          .toList(),
      schedules: (json['schedules'] as List? ?? [])
          .map((schedule) => ScheduleHomeModel.fromJson(schedule))
          .toList(),
    );
  }
}

class TeacherHomeModel {
  final String id;
  final UserHomeModel userId;

  TeacherHomeModel({
    required this.id,
    required this.userId,
  });

  factory TeacherHomeModel.fromJson(Map<String, dynamic> json) {
    return TeacherHomeModel(
      id: json['id']?.toString() ?? '',
      userId: UserHomeModel.fromJson(json['user_id'] ?? {}),
    );
  }
}

class UserHomeModel {
  final String id;
  final String name;
  final String email;
  final String profilePicture;
  final String role;

  UserHomeModel({
    required this.id,
    required this.name,
    required this.email,
    required this.profilePicture,
    required this.role,
  });

  factory UserHomeModel.fromJson(Map<String, dynamic> json) {
    return UserHomeModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      profilePicture: json['profile_picture']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
    );
  }
}

class AssignmentHomeModel {
  final String id;
  final String title;
  final String description;
  final String deadline;
  final String createdAt;

  AssignmentHomeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.deadline,
    required this.createdAt,
  });

  factory AssignmentHomeModel.fromJson(Map<String, dynamic> json) {
    return AssignmentHomeModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      deadline: json['deadline']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}

class ClassTestHomeModel {
  final String id;
  final String title;
  final String description;
  final String date;
  final String duration;
  final int totalMarks;

  ClassTestHomeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.duration,
    required this.totalMarks,
  });

  factory ClassTestHomeModel.fromJson(Map<String, dynamic> json) {
    return ClassTestHomeModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      duration: json['duration']?.toString() ?? '',
      totalMarks: json['total_marks'] ?? 0,
    );
  }
}