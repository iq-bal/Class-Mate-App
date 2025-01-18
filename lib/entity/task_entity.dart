class TaskParticipant {
  final String? id;
  final String? profilePicture;

  TaskParticipant({
    this.id,
    this.profilePicture,
  });

  factory TaskParticipant.fromJson(Map<String, dynamic> json) {
    return TaskParticipant(
      id: json['id'] as String?,
      profilePicture: json['profile_picture'] as String?,
    );
  }
}

class TaskEntity {
  final String? id;
  final String? title;
  final DateTime? date;
  final String? startTime;
  final String? endTime;
  final String? category;
  final List<TaskParticipant>? participants;

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
          ?.map((participant) => TaskParticipant.fromJson(participant as Map<String, dynamic>))
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
