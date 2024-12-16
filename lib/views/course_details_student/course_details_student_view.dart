import 'package:classmate/core/helper_function.dart';
import 'package:classmate/views/course_detail_teacher/widgets/assignment_card.dart';
import 'package:classmate/views/course_detail_teacher/widgets/course_card.dart';
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

  Widget _buildAttendanceChart() {
    return SizedBox(
      height: 80,
      width: 80,
      child: Stack(
        children: [
          CircularProgressIndicator(
            value: 0.85,
            backgroundColor: Colors.red.shade300,
            color: Colors.teal,
            strokeWidth: 8,
          ),
          const Center(
            child: Text(
              '85%',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresenceIndicators() {
    return Row(
      children: List.generate(8, (index) {
        bool isPresent = index < 5 || index == 7; // Mark some boxes as present
        return Container(
          margin: const EdgeInsets.only(right: 8),
          height: 24,
          width: 24,
          decoration: BoxDecoration(
            color: isPresent ? Colors.teal : Colors.red,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        );
      }),
    );
  }
}
