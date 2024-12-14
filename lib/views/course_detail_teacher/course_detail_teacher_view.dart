import 'dart:ffi';
import 'package:classmate/controllers/course_detail_teacher/course_detail_teacher_controller.dart';
import 'package:classmate/core/helper_function.dart';
import 'package:classmate/views/course_detail_teacher/widgets/assignment.dart';
import 'package:classmate/views/course_detail_teacher/widgets/course_card.dart';
import 'package:classmate/views/course_detail_teacher/widgets/custom_app_bar.dart';
import 'package:classmate/views/course_detail_teacher/widgets/student_list.dart';
import 'package:flutter/material.dart';
class CourseDetailScreen extends StatelessWidget {
  const CourseDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CourseDetailTeacherController courseDetailTeacherController = CourseDetailTeacherController();
    courseDetailTeacherController.fetchCourseDetails('675c910186e75d98dc7c5cae',"A","Monday"); // Fetch details on load
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Course Detail',
        onBackPressed: () {
          // Handle back button press
          Navigator.of(context).pop();
        },
        onMorePressed: () {
          // Handle more button press
          print('More button pressed');
        },
      ),
      body: ValueListenableBuilder<CourseDetailState>(
          valueListenable: courseDetailTeacherController.stateNotifier,
          builder: (context,state,child){
            if(state==CourseDetailState.loading){
              return const Center(child: CircularProgressIndicator());
            }
            else if(state==CourseDetailState.error){
              return Center(child: Text(courseDetailTeacherController.errorMessage ?? 'Error occurred'));
            }
            else if(state == CourseDetailState.success && courseDetailTeacherController.courseDetail != null){
              final course = courseDetailTeacherController.courseDetail!;
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Course Info Row
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
                        students: course.enrolledStudents.map((user) => {
                          'name': user.name,
                          'id': user.id,
                          'isPresent': false, // Default to false or set logic based on your app
                        }).toList(),
                        showViewAll: true,
                        onViewAllPressed: () {
                          debugPrint('View All Pressed');
                        },
                      ),

                      AssignmentContainer(
                        assignments: course.assignments.map((assignment) =>
                            Assignment(
                                title: assignment.title.toString(),
                                description: assignment.description.toString(),
                                dueDate: 'Due ${HelperFunction.formatTimestamp(assignment.deadline.toString()).toString()}',
                                iconText: HelperFunction.getFirstTwoLettersUppercase(assignment.title.toString()),
                                totalItems: assignment.submissions.length
                            )
                        ).toList(), // Pass the list of assignments here
                        onCreateAssignment: () {
                          // Handle create assignment action
                          print('Create Assignment clicked');
                        },
                      ),
                    ],
                  ),
                ),
              );
            }
            return const Center(child: Text('No data available'));
          },
      ),
    );
  }
}
