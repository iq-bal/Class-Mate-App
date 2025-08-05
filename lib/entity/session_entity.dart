class SessionEntity {
  final String? id;
  final String? title;
  final String? description;
  final String? date;
  final String? startTime;
  final String? endTime;
  final String? status;
  final String? meetingLink;
  final String? topic;
  final String? createdAt;
  final String? updatedAt;

  const SessionEntity({
    this.id,
    this.title,
    this.description,
    this.date,
    this.startTime,
    this.endTime,
    this.status,
    this.meetingLink,
    this.topic,
    this.createdAt,
    this.updatedAt,
  });

  // Factory method to create a SessionEntity from JSON
  factory SessionEntity.fromJson(Map<String, dynamic> json) {
    return SessionEntity(
      id: json['id'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      date: json['date'] as String?,
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
      status: json['status'] as String?,
      meetingLink: json['meeting_link'] as String?,
      topic: json['topic'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  // Method to convert a SessionEntity to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date,
      'start_time': startTime,
      'end_time': endTime,
      'status': status,
      'meeting_link': meetingLink,
      'topic': topic,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}