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

  // Factory constructor to create a UserModel object from a JSON map
  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
        section: json['section'].toString(), // Extracts 'id' from the JSON map
        roomNo: json['room_no'].toString(), // Extracts 'email' from the JSON map
        day: json['day'].toString(), // Extracts 'name' from the JSON map
        startTime: json['start_time'].toString(), // Extracts 'role' from the JSON map
        endTime: json['end_time'].toString()
    );
  }
}
