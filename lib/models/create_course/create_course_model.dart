import 'dart:convert';

class CreateCourseModel {
  String id;
  String title;
  String courseCode;
  double credit;
  String description;
  String? excerpt;
  String? image;

  CreateCourseModel({
    required this.id,
    required this.title,
    required this.courseCode,
    required this.credit,
    required this.description,
    this.excerpt,
    this.image,
  });
  factory CreateCourseModel.fromJson(Map<String, dynamic> json) {
    return CreateCourseModel(
      id: json['id'],
      title: json['title'],
      courseCode: json['course_code'],
      credit: json['credit'].toDouble(),
      description: json['description'],
      excerpt: json['excerpt'],
      image: json['image'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'course_code': courseCode,
      'credit': credit,
      'description': description,
      'excerpt': excerpt,
      'image': image,
    };
  }
}
