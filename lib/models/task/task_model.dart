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
    return TaskModel(
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

  // Method to convert TaskModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'date': date?.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'category': category,
      'participants': participants,
    };
  }
}
