import 'package:flutter/material.dart';
import 'package:classmate/controllers/class_details_student/class_details_student_controller.dart';
import 'package:classmate/views/assignment/assignment_detail_view.dart';
import 'package:classmate/views/class_details_student/widgets/attendance_summary.dart';
import 'package:classmate/views/class_details_student/widgets/course_card_student.dart';
import 'package:classmate/views/class_details_student/widgets/custom_tab_bar.dart';
import 'package:classmate/views/assignment/widgets/custom_app_bar.dart';

import '../../core/helper_function.dart';
import '../course_detail_teacher/widgets/assignment_card.dart';

class ClassDetailsStudent extends StatefulWidget {
  // final String courseId;
  // final String day;
  // final String teacherId;

  const ClassDetailsStudent({
    super.key,
    // required this.courseId,
    // required this.day,
    // required this.teacherId,
  });

  @override
  State<ClassDetailsStudent> createState() => _ClassDetailsStudentState();
}

class _ClassDetailsStudentState extends State<ClassDetailsStudent> {
  final ClassDetailsStudentController _controller = ClassDetailsStudentController();

  @override
  void initState() {
    super.initState();
    _fetchClassDetails();
  }

  void _fetchClassDetails() {
    const courseId = "675c9104b6f24d432eb28707";
    const day = "Friday";
    const teacherId = "67700aaf73eeab1f443ac463";
    // _controller.fetchClassDetails(widget.courseId, widget.day, widget.teacherId);
    _controller.fetchClassDetails(courseId, day, teacherId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ValueListenableBuilder<CourseDetailStudentState>(
          valueListenable: _controller.stateNotifier,
          builder: (context, state, child) {
            if (state == CourseDetailStudentState.loading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state == CourseDetailStudentState.error) {
              return Center(
                child: Text(
                  _controller.errorMessage ?? "An error occurred while fetching class details.",
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              );
            } else if (state == CourseDetailStudentState.success) {
              final details = _controller.classDetails;
              if (details == null) {
                return const Center(child: Text("No class details available."));
              }

              // UI for successful data fetch
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomAppBar(
                      title: "Class Details",
                      onBackPress: () {
                        Navigator.pop(context);
                      },
                      onMorePress: () {
                        print("More options clicked");
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: CourseCardStudent(
                        courseCode: details.course.courseCode ?? "N/A",
                        className: details.schedule?.section ?? "N/A",
                        day: details.schedule?.day ?? "N/A",
                        time: "${HelperFunction.cleanTime(details.schedule?.startTime ?? "")} - ${HelperFunction.cleanTime(details.schedule?.endTime ?? "")}",
                        title: details.course.title ?? "N/A",
                        roomNo: details.schedule?.roomNo ?? "N/A",
                      ),
                    ),
                    const SizedBox(height: 16),

                    AttendanceSummary(
                      attendancePercentage: details.attendanceList.isEmpty
                          ? 0.0
                          : details.attendanceList
                          .where((e) => e.status?.toLowerCase() == "present")
                          .length /
                          details.attendanceList.length,
                      presenceIndicators: details.attendanceList
                          .map((e) => e.status?.toLowerCase() == "present" ? true : false)
                          .toList(),
                      feedbackText: HelperFunction.getAttendanceFeedback(
                        details.attendanceList.isEmpty
                            ? 0.0
                            : details.attendanceList
                            .where((e) => e.status?.toLowerCase() == "present")
                            .length /
                            details.attendanceList.length,
                      ),
                    ),





                    const SizedBox(height: 16),
                    const CustomTabBar(),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Assignments',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...details.assignments.map((assignment) {
                            return AssignmentCard(
                              title: assignment.title ?? "No Title",
                              description: assignment.description ?? "No Description",
                              dueDate: HelperFunction.formatTimestamp(
                                DateTime.parse(assignment.deadline?.toString() ?? "").millisecondsSinceEpoch.toString(),
                              ),
                              iconText: HelperFunction.getFirstTwoLettersUppercase(
                                assignment.title ?? "",
                              ),
                              totalItems: 12, // Placeholder or dynamic count
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AssignmentDetailPage(),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return const Center(child: Text("Unexpected state encountered."));
            }
          },
        ),
      ),
    );
  }
}
