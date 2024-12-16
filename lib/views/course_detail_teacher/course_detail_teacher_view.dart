import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:classmate/controllers/course_detail_teacher/course_detail_teacher_controller.dart';
import 'package:classmate/core/helper_function.dart';
import 'package:classmate/views/course_detail_teacher/widgets/assignment.dart';
import 'package:classmate/views/course_detail_teacher/widgets/course_card.dart';
import 'package:classmate/views/course_detail_teacher/widgets/create_assignment_modal.dart';
import 'package:classmate/views/course_detail_teacher/widgets/custom_app_bar.dart';
import 'package:classmate/views/course_detail_teacher/widgets/student_list.dart';

class CourseDetailScreen extends StatefulWidget {
  const CourseDetailScreen({super.key});

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
    courseDetailTeacherController.fetchCourseDetails('675c910186e75d98dc7c5cae', "A", "Monday");
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
      builder: (context) => CreateAssignmentModal(courseId: '675c910186e75d98dc7c5cae',
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

  @override
  Widget build(BuildContext context) {
    final CourseDetailTeacherController courseDetailTeacherController =
    CourseDetailTeacherController();
    courseDetailTeacherController.fetchCourseDetails(
        '675c910186e75d98dc7c5cae', "A", "Monday"); // Fetch details on load

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
                final course = courseDetailTeacherController.courseDetail!;
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CourseCard(
                          courseCode: course.courseCode,
                          className: 'Class ${course.schedule.section}',
                          day: course.schedule.day,
                          time: course.schedule.startTime,
                          title: course.title,
                          roomNo: course.schedule.roomNo,
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
                            'name': user.name,
                            'id': user.id,
                            'isPresent': false,
                          })
                              .toList(),
                          showViewAll: true,
                          onViewAllPressed: () {
                            debugPrint('View All Pressed');
                          },
                        ),
                        AssignmentContainer(
                          assignments: course.assignments
                              .map((assignment) => Assignment(
                            title: assignment.title.toString(),
                            description:
                            assignment.description.toString(),
                            dueDate:
                            'Due ${HelperFunction.formatTimestamp(assignment.deadline.toString()).toString()}',
                            iconText: HelperFunction
                                .getFirstTwoLettersUppercase(
                                assignment.title.toString()),
                            totalItems: assignment.submissions.length,
                          ))
                              .toList(),
                          onCreateAssignment: () =>
                              showCreateAssignmentModal(context),
                        ),
                      ],
                    ),
                  ),
                );
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
