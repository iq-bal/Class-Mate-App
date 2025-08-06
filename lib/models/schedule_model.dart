class ScheduleModel{
  final String? id;
  final String section;
  final String roomNo;
  final String day;
  final String startTime;
  final String endTime;


  ScheduleModel({
    this.id,
    required this.section,
    required this.roomNo,
    required this.day,
    required this.startTime,
    required this.endTime
  });

  // Factory constructor to create a ScheduleModel object from a JSON map
  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
        id: json['_id']?.toString() ?? json['id']?.toString(),
        section: json['section']?.toString() ?? '',
        roomNo: json['room_number']?.toString() ?? '',
        day: json['day']?.toString() ?? '',
        startTime: json['start_time']?.toString() ?? '',
        endTime: json['end_time']?.toString() ?? ''
    );
  }
}
