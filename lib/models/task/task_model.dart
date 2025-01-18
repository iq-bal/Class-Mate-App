import 'package:classmate/entity/task_entity.dart';

class TaskModel extends TaskEntity {

  TaskModel({
    super.id,
    required super.title,
    required super.date,
    required super.startTime,
    required super.endTime,
    required super.category,
    required super.participants,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic dateValue) {
      if (dateValue == null) return null;
      
      // Convert string timestamp to int
      if (dateValue is String) {
        return DateTime.fromMillisecondsSinceEpoch(int.parse(dateValue));
      }
      
      if (dateValue is int) {
        return DateTime.fromMillisecondsSinceEpoch(dateValue);
      }
      
      return DateTime.parse(dateValue.toString());
    }

    return TaskModel(
      id: json['id'] as String?,
      title: json['title'] as String?,
      date: parseDate(json['date']),
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
      category: json['category'] as String?,
      participants: (json['participants'] as List<dynamic>?)
          ?.map((participant) => TaskParticipant.fromJson(participant))
          .toList() ?? [],
    );
  }
  // Method to convert TaskModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'date': date?.toIso8601String().split('T')[0],
      'start_time': startTime,
      'end_time': endTime,
      'category': category?.toLowerCase(),
      'participants': participants?.map((p) => p.id).toList() ?? [],
    };
  }
  
}
