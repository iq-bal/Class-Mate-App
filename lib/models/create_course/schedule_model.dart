class ScheduleModel {
  final String id;
  final String courseId;
  final String day;
  final String section;
  final String startTime;
  final String endTime;
  final String roomNumber;

  // Constructor
  ScheduleModel({
    required this.id,
    required this.courseId,
    required this.day,
    required this.section,
    required this.startTime,
    required this.endTime,
    required this.roomNumber,
  });

  // Factory method to create a ScheduleModel from JSON
  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'] as String,
      courseId: json['course_id'] as String,
      day: json['day'] as String,
      section: json['section'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      roomNumber: json['room_number'] as String,
    );
  }

  // Method to convert ScheduleModel to JSON for mutation input
  Map<String, dynamic> toJson() {
    return {
      'course_id':courseId,
      'day': day,
      'section': section,
      'start_time': startTime,
      'end_time': endTime,
      'room_number': roomNumber,
    };
  }
}
