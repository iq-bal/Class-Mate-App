import 'package:classmate/core/helper_function.dart';
import 'package:classmate/views/assignment/assignment_detail_view.dart';
import 'package:classmate/views/course_detail_teacher/widgets/assignment_card.dart';
import 'package:classmate/views/course_details_student/widgets/attendance_summary.dart';
import 'package:classmate/views/course_details_student/widgets/course_card_student.dart';
import 'package:classmate/views/course_details_student/widgets/custom_tab_bar.dart';
import 'package:flutter/material.dart';

class CourseDetailsStudent extends StatelessWidget {
  const CourseDetailsStudent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Class Detail',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: const Icon(Icons.arrow_back, color: Colors.black),
        actions: const [
          Icon(Icons.more_vert, color: Colors.black),
        ],
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course Title Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CourseCardStudent(courseCode: "CSE 3202", className: "B", day: "Monday", time: "07-09 AM", title: "Computer Architecture & Organization", roomNo: "CSE 502"),
                ],
              ),
            ),
            const SizedBox(height: 16),

            const AttendanceSummary(
              attendancePercentage: 0.40, // 85% attendance
              presenceIndicators: [
                true, true, true, true, true, false, false, true, false, true
              ],
              feedbackText: 'Your Presence this time is good',
            ),

            const SizedBox(height: 16),

            CustomTabBar(),

            const SizedBox(height: 20),

            // Assignment Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Aligns children to the left
                children: [
                  const Text(
                    'Today',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold, height: 1.2),
                  ),
                  const SizedBox(height: 16),
                  AssignmentCard(
                    title: "Cache Memory Performance Evaluation",
                    description: "Solve problem 1-10 of chapter 4",
                    dueDate: "25 Dec 2024",
                    iconText: HelperFunction.getFirstTwoLettersUppercase("Cache Memory Performance Evaluation"),
                    totalItems: 12,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>const AssignmentDetailPage()));
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // _buildAssignmentCard(),
          ],
        ),
      ),
    );
  }
}
