import 'package:classmate/controllers/course_detail_teacher/course_detail_teacher_controller.dart';
import 'package:classmate/views/course_detail_teacher/widgets/assignment.dart';
import 'package:classmate/views/course_detail_teacher/widgets/assignment_card.dart';
import 'package:classmate/views/course_detail_teacher/widgets/course_card.dart';
import 'package:classmate/views/course_detail_teacher/widgets/not_found.dart';
import 'package:classmate/views/course_detail_teacher/widgets/student_list.dart';
import 'package:flutter/material.dart';

class CourseDetailScreen extends StatelessWidget {
  const CourseDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CourseDetailTeacherController _courseDetailTeacherController = CourseDetailTeacherController();

    void _checkbtn(){
      const String c_id = "675c910186e75d98dc7c5cae";
      _courseDetailTeacherController.fetchCourseDetails(c_id);
    }

    final List<Map<String, dynamic>> students = [
      {'name': 'Iqbal Mahamud', 'id': '2007091', 'isPresent': true},
      {'name': 'Sarah Ahmed', 'id': '2007092', 'isPresent': true},
      {'name': 'Ayesha Siddiqui', 'id': '2007093', 'isPresent': false},
    ];

    // Sample data
    final List<Assignment> assignments = [
      Assignment(
        title: 'Cache Memory Performance Evaluation',
        description: 'Solve problem 1-10 of chapter 4, and ensure proper implementation.',
        dueDate: 'Due June 5, 2025',
        iconText: 'CH',
        totalItems: 12,
      ),
      Assignment(
        title: 'Pipeline Design Analysis',
        description: 'Prepare a report on pipeline hazards.',
        dueDate: 'Due June 10, 2025',
        iconText: 'PD',
        totalItems: 8,
      ),
    ];


    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Course Detail',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course Info Row
              CourseCard(
                courseCode: 'CSE 305',
                className: 'Class B',
                day: 'Tuesday',
                time: '07:09 AM',
                title: 'Computer Architecture & Organizations',
                roomNo: 'CS101',
                onAttend: () {
                  print('Attend button pressed');
                },
                onReschedule: () {
                  print('Reschedule button pressed');
                },
              ),
              const SizedBox(height: 24),
              StudentList(students: students, showViewAll: true,onViewAllPressed: () {
                // Handle "View All" button press
                debugPrint('View All Pressed');
              }),

              AssignmentContainer(
                assignments: assignments, // Pass the list of assignments here
                onCreateAssignment: () {
                  // Handle create assignment action
                  print('Create Assignment clicked');
                },
              ),
              Container(
                padding: EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    _checkbtn();
                  },
                  child: Text('Click Me'), // Text inside the button
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
