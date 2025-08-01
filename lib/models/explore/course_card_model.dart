class CourseCardModel {
  final String id;
  final String title;
  final String courseCode;
  final String excerpt;

  CourseCardModel({
    required this.id,
    required this.title,
    required this.courseCode,
    required this.excerpt,
  });

  // Factory method to create a Course from JSON
  factory CourseCardModel.fromJson(Map<String, dynamic> json) {
    return CourseCardModel(
      id: json['id'] as String,
      title: json['title'] as String,
      courseCode: json['course_code'] as String,
      excerpt: json['excerpt'] as String,
    );
  }

  // Method to convert the Course object back to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'course_code': courseCode,
      'excerpt': excerpt,
    };
  }
}
