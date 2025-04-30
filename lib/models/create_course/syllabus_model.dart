class SyllabusModel {
  final String id;
  final String courseId;
  final Map<String, List<String>> syllabus;

  SyllabusModel({
    required this.id,
    required this.courseId,
    required this.syllabus,
  });

  factory SyllabusModel.fromJson(Map<String, dynamic> json) {
    final rawSyllabus = json['syllabus'] as Map<String, dynamic>;

    // Safely cast nested lists of strings
    final parsedSyllabus = rawSyllabus.map(
          (key, value) => MapEntry(
        key,
        List<String>.from(value as List),
      ),
    );

    return SyllabusModel(
      id: json['id'] as String,
      courseId: json['course_id'] as String,
      syllabus: parsedSyllabus,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'syllabus': syllabus,
    };
  }
}
