class TaskEntity {
  final String? id;
  final String? title;
  final DateTime? date;
  final String? startTime;
  final String? endTime;
  final String? category;
  final List<String>? participants;

  TaskEntity({
    this.id,
    this.title,
    this.date,
    this.startTime,
    this.endTime,
    this.category,
    this.participants,
  });

  // Factory constructor to create a TaskEntity from JSON
  factory TaskEntity.fromJson(Map<String, dynamic> json) {
    return TaskEntity(
      id: json['id'] as String?,
      title: json['title'] as String?,
      date: json['date'] != null ? DateTime.parse(json['date'] as String) : null,
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      category: json['category'] as String?,
      participants: (json['participants'] as List<dynamic>?)
          ?.map((participant) => participant as String)
          .toList(),
    );
  }

  // Method to convert TaskEntity to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date?.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'category': category,
      'participants': participants,
    };
  }
}
