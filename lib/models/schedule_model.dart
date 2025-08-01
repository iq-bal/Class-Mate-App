class ScheduleModel{
  final String section;
  final String roomNo;
  final String day;
  final String startTime;
  final String endTime;


  ScheduleModel({
    required this.section,
    required this.roomNo,
    required this.day,
    required this.startTime,
    required this.endTime
  });

  // Factory constructor to create a ScheduleModel object from a JSON map
  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
        section: json['section']?.toString() ?? '',
        roomNo: json['room_number']?.toString() ?? '',
        day: json['day']?.toString() ?? '',
        startTime: json['start_time']?.toString() ?? '',
        endTime: json['end_time']?.toString() ?? ''
    );
  }
}
