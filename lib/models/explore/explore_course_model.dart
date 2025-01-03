import 'package:classmate/entity/course_entity.dart';

class ExploreCourseModel extends CourseEntity{
  const ExploreCourseModel({
      super.id,
      super.title,
      super.courseCode,
      super.description
  }):super(
    teacherId: null,
    createdAt: null,
  );

  // Factory method to create an ExploreCourseModel from JSON
  factory ExploreCourseModel.fromJson(Map<String, dynamic> json) {
    return ExploreCourseModel(
      id: json['id'] as String?,
      title: json['title'] as String?,
      courseCode: json['course_code'] as String?,
      description: json['description'] as String?,
    );
  }
}