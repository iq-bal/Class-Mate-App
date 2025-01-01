class SyllabusEntity {
  final String? id;
  final Map<String, List<String>>? syllabus; // A map of modules to subtopics
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SyllabusEntity({
    this.id,
    this.syllabus,
    this.createdAt,
    this.updatedAt,
  });

  // Factory method to create a SyllabusEntity from JSON
  factory SyllabusEntity.fromJson(Map<String, dynamic> json) {
    var syllabusMap = json['syllabus'] as Map<String, dynamic>?;
    Map<String, List<String>> syllabus = {};

    if (syllabusMap != null) {
      syllabusMap.forEach((key, value) {
        syllabus[key] = List<String>.from(value);
      });
    }

    return SyllabusEntity(
      id: json['id'] as String?,
      syllabus: syllabus.isNotEmpty ? syllabus : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }
}
