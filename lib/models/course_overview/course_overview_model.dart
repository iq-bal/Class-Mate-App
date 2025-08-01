class CourseOverviewModel {
  final String id;
  final String title;
  final String description;
  final String image;
  final double credit;
  final double averageRating;
  final TeacherModel teacher;
  final SyllabusModel syllabus;
  final List<ReviewModel> reviews;

  CourseOverviewModel({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.credit,
    required this.averageRating,
    required this.teacher,
    required this.syllabus,
    required this.reviews,
  });

  factory CourseOverviewModel.fromJson(Map<String, dynamic> json) {
    return CourseOverviewModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      image: json['image'] as String? ?? '',
      credit: json['credit'] != null ? (json['credit'] as num).toDouble() : 0.0,
      averageRating: json['averageRating'] != null ? (json['averageRating'] as num).toDouble() : 0.0,
      teacher: json['teacher'] != null
          ? TeacherModel.fromJson(json['teacher'] as Map<String, dynamic>)
          : TeacherModel(id: '', userId: UserModel(name: '', profilePicture: ''), about: '', designation: ''),
      syllabus: json['syllabus'] != null
          ? SyllabusModel.fromJson(json['syllabus'] as Map<String, dynamic>)
          : SyllabusModel(syllabus: {}),
      reviews: (json['reviews'] as List<dynamic>?)
          ?.map((review) => ReviewModel.fromJson(review as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

class TeacherModel {
  final String id;
  final UserModel userId;
  final String about;
  final String designation;

  TeacherModel({
    required this.id,
    required this.userId,
    required this.about,
    required this.designation,
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] != null
          ? UserModel.fromJson(json['user_id'] as Map<String, dynamic>)
          : UserModel(name: '', profilePicture: ''),
      about: json['about'] as String? ?? '',
      designation: json['designation'] as String? ?? '',
    );
  }
}

class UserModel {
  final String name;
  final String profilePicture;

  UserModel({
    required this.name,
    required this.profilePicture,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] as String? ?? '',
      profilePicture: json['profile_picture'] as String? ?? '',
    );
  }
}

class SyllabusModel {
  final Map<String, dynamic> syllabus;

  SyllabusModel({
    required this.syllabus,
  });

  factory SyllabusModel.fromJson(Map<String, dynamic> json) {
    return SyllabusModel(
      syllabus: json['syllabus'] as Map<String, dynamic>? ?? {},
    );
  }
}

class ReviewModel {
  final String id;
  final double rating;
  final String comment;
  final String createdAt;
  final UserModel commentedBy;

  ReviewModel({
    required this.id,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.commentedBy,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String? ?? '',
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : 0.0,
      comment: json['comment'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      commentedBy: json['commented_by'] != null
          ? UserModel.fromJson(json['commented_by'] as Map<String, dynamic>)
          : UserModel(name: '', profilePicture: ''),
    );
  }
}