class PopularCardModel {
  final String id;
  final String title;
  final String excerpt;
  final int enrolled;
  final String courseCode;

  PopularCardModel({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.enrolled,
    required this.courseCode
  });

  factory PopularCardModel.fromJson(Map<String, dynamic> json) {
    return PopularCardModel(
      id: json['id'] as String,
      title: json['title'] as String,
      excerpt: json['excerpt'] as String,
      enrolled: json['enrolled'] as int,
      courseCode: json['course_code'] as String
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'excerpt': excerpt,
      'enrolled': enrolled,
    };
  }
}
