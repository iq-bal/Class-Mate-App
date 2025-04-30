class ProfileTeacherModel {
  final String id;
  final String name;
  final String email;
  final String? profilePicture;  // Nullable field
  final String? coverPicture;    // Nullable field
  final Teacher? teacher;
  final List<Course>? courses;

  ProfileTeacherModel({
    required this.id,
    required this.name,
    required this.email,
    this.profilePicture,
    this.coverPicture,
    this.teacher,
    this.courses,
  });

  // Factory constructor to create ProfileTeacherModel from JSON
  factory ProfileTeacherModel.fromJson(Map<String, dynamic> json) {
    return ProfileTeacherModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      profilePicture: json['profile_picture'] as String?,  // Make nullable
      coverPicture: json['cover_picture'] as String?,      // Make nullable
      teacher: json['teacher'] != null ? Teacher.fromJson(json['teacher']) : null,
      courses: json['courses'] != null
          ? List<Course>.from(json['courses'].map((course) => Course.fromJson(course)))
          : [],
    );
  }
}

class Teacher {
  final String id;
  final String about;
  final String designation;
  final String department;

  Teacher({
    required this.id,
    required this.about,
    required this.designation,
    required this.department,
  });

  // Factory constructor to create Teacher from JSON
  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['id'] as String,
      about: json['about'] as String,
      designation: json['designation'] as String,
      department: json['department'] as String,
    );
  }
}

class Course {
  final String id;
  final String title;
  final String image;

  Course({
    required this.id,
    required this.title,
    required this.image,
  });

  // Factory constructor to create Course from JSON
  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as String,
      title: json['title'] as String,
      image: json['image'] as String,
    );
  }
}
