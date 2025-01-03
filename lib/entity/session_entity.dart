class SessionEntity {
  final String? id;
  final DateTime? date;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? topic;

  const SessionEntity({
    this.id,
    this.date,
    this.startTime,
    this.endTime,
    this.topic,
  });

  // Factory method to create a SessionEntity from JSON
  factory SessionEntity.fromJson(Map<String, dynamic> json) {
    return SessionEntity(
      id: json['id'] as String?,
      date: json['date'] != null ? DateTime.parse(json['date'] as String) : null,
      startTime: json['start_time'] != null ? DateTime.parse(json['start_time'] as String) : null,
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time'] as String) : null,
      topic: json['topic'] as String?,
    );
  }

  // Method to convert a SessionEntity to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date?.toIso8601String(),
      'start_time': startTime?.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'topic': topic,
    };
  }
}