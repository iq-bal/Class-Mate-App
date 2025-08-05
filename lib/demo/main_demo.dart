import 'package:flutter/material.dart';
import 'package:classmate/demo/realtime_attendance_demo.dart';

void main() {
  runApp(const RealtimeAttendanceDemoApp());
}

class RealtimeAttendanceDemoApp extends StatelessWidget {
  const RealtimeAttendanceDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Real-time Attendance Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const RealtimeAttendanceDemo(),
      debugShowCheckedModeBanner: false,
    );
  }
}