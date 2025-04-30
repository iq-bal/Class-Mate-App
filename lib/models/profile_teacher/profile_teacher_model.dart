class ProfileTeacherModel {
  String id;
  String name;
  String email;
  String? profilePicture;  // Nullable and mutable
  String? coverPicture;    // Nullable and mutable
  Teacher? teacher;        // Nullable and mutable reference
  List<Course>? courses;   // Nullable and mutable

  ProfileTeacherModel({
    required this.id,
    required this.name,
    required this.email,
    this.profilePicture,
    this.coverPicture,
    this.teacher,
    this.courses,
  });

  factory ProfileTeacherModel.fromJson(Map<String, dynamic> json) {
    return ProfileTeacherModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      profilePicture: json['profile_picture'] as String?,
      coverPicture: json['cover_picture'] as String?,
      teacher: json['teacher'] != null
          ? Teacher.fromJson(json['teacher'] as Map<String, dynamic>)
          : null,
      courses: json['courses'] != null
          ? List<Course>.from(
        (json['courses'] as List<dynamic>)
            .map((e) => Course.fromJson(e as Map<String, dynamic>)),
      )
          : <Course>[],
    );
  }
}

class Teacher {
  String id;
  String about;
  String designation;
  String department;

  Teacher({
    required this.id,
    required this.about,
    required this.designation,
    required this.department,
  });

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

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as String,
      title: json['title'] as String,
      image: json['image'] as String,
    );
  }
}
