class ClassTestEntity {
  final String id;
  final String title;
  final String description;
  final String date;
  final int duration;
  final int totalMarks;
  final String createdAt;

  ClassTestEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.duration,
    required this.totalMarks,
    required this.createdAt,
  });

  // Factory constructor to create a ClassTestEntity object from JSON
  factory ClassTestEntity.fromJson(Map<String, dynamic> json) {
    return ClassTestEntity(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      duration: json['duration'] as int? ?? 0,
      totalMarks: json['total_marks'] as int? ?? 0,
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date,
      'duration': duration,
      'total_marks': totalMarks,
      'created_at': createdAt,
    };
  }
}