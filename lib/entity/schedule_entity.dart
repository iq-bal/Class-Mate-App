class ScheduleEntity {
  final String? id;
  final String section;
  final String roomNo;
  final String day;
  final String startTime;
  final String endTime;

  const ScheduleEntity({
    this.id,
    required this.section,
    required this.roomNo,
    required this.day,
    required this.startTime,
    required this.endTime,
  });

  // Factory method to create a ScheduleEntity from JSON
  factory ScheduleEntity.fromJson(Map<String, dynamic> json) {
    return ScheduleEntity(
      id: json['id'] as String?,
      section: json['section'] as String,
      roomNo: json['room_no'] as String,
      day: json['day'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
    );
  }

  // Method to convert a ScheduleEntity to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'section': section,
      'room_no': roomNo,
      'day': day,
      'start_time': startTime,
      'end_time': endTime,
    };
  }
}
