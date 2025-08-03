import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:classmate/controllers/course_detail_teacher/course_detail_teacher_controller.dart';
import 'package:classmate/core/helper_function.dart';
import 'package:classmate/views/course_detail_teacher/widgets/assignment.dart';
import 'package:classmate/views/course_detail_teacher/widgets/class_test.dart';
import 'package:classmate/views/course_detail_teacher/widgets/course_card.dart';
import 'package:classmate/views/course_detail_teacher/widgets/create_assignment_modal.dart';
import 'package:classmate/views/course_detail_teacher/widgets/create_class_test_modal.dart';
import 'package:classmate/views/course_detail_teacher/widgets/custom_app_bar.dart';
import 'package:classmate/views/course_detail_teacher/widgets/student_list.dart';
import 'package:classmate/views/course_detail_teacher/enrollment_management_view.dart';

class CourseDetailScreen extends StatefulWidget {
  final String courseId;
  
  const CourseDetailScreen({
    super.key, 
    required this.courseId
  });

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  bool _isModalOpen = false;
  final CourseDetailTeacherController courseDetailTeacherController = CourseDetailTeacherController();

  @override
  void initState() {
    super.initState();
    _fetchCourseDetails();
  }

  void _fetchCourseDetails() {
    courseDetailTeacherController.fetchCourseDetails(
      widget.courseId
    );
  }

  void showCreateAssignmentModal(BuildContext context) {
    setState(() {
      _isModalOpen = true;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CreateAssignmentModal(
        courseId: widget.courseId,
        onAssignmentCreated: () {
          _fetchCourseDetails();
        },
      ),
    ).whenComplete(() {
      // Reset modal state when closed
      setState(() {
        _isModalOpen = false;
      });
    });
  }

  void showCreateClassTestModal(BuildContext context) {
    setState(() {
      _isModalOpen = true;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CreateClassTestModal(
        courseId: widget.courseId,
        onClassTestCreated: () {
          _fetchCourseDetails();
        },
      ),
    ).whenComplete(() {
      // Reset modal state when closed
      setState(() {
        _isModalOpen = false;
      });
    });
  }

  String _formatClassTestDate(String dateString) {
    try {
      DateTime date;
      // Check if the dateString is a timestamp (all digits)
      if (RegExp(r'^\d+$').hasMatch(dateString)) {
        // Convert timestamp to DateTime
        final timestamp = int.parse(dateString);
        date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      } else {
        // Parse as ISO date string
        date = DateTime.parse(dateString);
      }
      
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: CustomAppBar(
            title: 'Course Detail',
            onBackPressed: () {
              Navigator.of(context).pop();
            },
            onMorePressed: () {
              print('More button pressed');
            },
          ),
          body: ValueListenableBuilder<CourseDetailState>(
            valueListenable: courseDetailTeacherController.stateNotifier,
            builder: (context, state, child) {
              if (state == CourseDetailState.loading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state == CourseDetailState.error) {
                return Center(
                    child: Text(courseDetailTeacherController.errorMessage ??
                        'Error occurred'));
              } else if (state == CourseDetailState.success &&
                  courseDetailTeacherController.courseDetail != null) {
                try {
                  final course = courseDetailTeacherController.courseDetail!;
                  return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CourseCard(
                          courseCode: course.courseCode ?? 'No Code',
                          className: 'Class ${course.schedules.isNotEmpty ? course.schedules[0].section : 'Unknown'}',
                          day: course.schedules.isNotEmpty ? course.schedules[0].day : 'No Day',
                          time: course.schedules.isNotEmpty ? course.schedules[0].startTime : 'No Time',
                          title: course.title ?? 'No Title',
                          roomNo: course.schedules.isNotEmpty ? course.schedules[0].roomNo : 'No Room',
                          onAttend: () {
                            print('Attend button pressed');
                          },
                          onReschedule: () {
                            print('Reschedule button pressed');
                          },
                        ),
                        const SizedBox(height: 24),
                        StudentList(
                          students: course.enrolledStudents
                              .map((user) => {
                            'name': user.name ?? 'Unknown Student',
                            'id': user.id ?? '',
                            'roll': user.roll ?? 'No Roll',
                            'profilePicture': user.profilePicture,
                            'isPresent': false,
                          })
                              .toList(),
                          showViewAll: true,
                          onViewAllPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EnrollmentManagementView(
                                  courseId: widget.courseId,
                                ),
                              ),
                            );
                          },
                        ),
                        AssignmentContainer(
                          assignments: course.assignments
                              .map((assignment) => Assignment(
                            id: assignment.id?.toString() ?? '',
                            title: assignment.title?.toString() ?? 'No Title',
                            description: assignment.description?.toString() ?? 'No Description',
                            dueDate: assignment.deadline != null 
                                ? HelperFunction.formatISODate(assignment.deadline.toString())
                                : 'No Due Date',
                            iconText: assignment.title != null
                                ? HelperFunction.getFirstTwoLettersUppercase(assignment.title.toString())
                                : 'NA',
                            totalItems: assignment.submissions?.length ?? 0,
                          ))
                              .toList(),
                          onCreateAssignment: () =>
                              showCreateAssignmentModal(context),
                        ),
                        const SizedBox(height: 24),
                        ClassTestContainer(
                          classTests: course.classTests
                              .map((classTest) => ClassTest(
                            id: classTest.id,
                            title: classTest.title,
                            description: classTest.description,
                            date: classTest.date.isNotEmpty 
                                ? _formatClassTestDate(classTest.date)
                                : 'No Date',
                            iconText: classTest.title.isNotEmpty
                                ? HelperFunction.getFirstTwoLettersUppercase(classTest.title)
                                : 'CT',
                            duration: classTest.duration,
                            totalMarks: classTest.totalMarks,
                          ))
                              .toList(),
                          onCreateClassTest: () =>
                              showCreateClassTestModal(context),
                        ),
                      ],
                    ),
                  ),
                );
                } catch (e) {
                  return Center(
                    child: Text('Error displaying course data: $e')
                  );
                }
              }
              return const Center(child: Text('No data available'));
            },
          ),
        ),
        if (_isModalOpen)
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Apply blur effect
            child: Container(
              color: Colors.black.withOpacity(0.5), // Add dimming overlay
            ),
          ),
      ],
    );
  }
}
