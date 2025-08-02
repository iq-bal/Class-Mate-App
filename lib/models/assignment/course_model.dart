class CourseModel {
  final String id;
  final String title;
  final String courseCode;
  final String description;

  const CourseModel({
    required this.id,
    required this.title,
    required this.courseCode,
    required this.description,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      courseCode: json['course_code'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }
}