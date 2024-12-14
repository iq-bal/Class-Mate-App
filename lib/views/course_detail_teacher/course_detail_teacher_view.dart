import 'package:classmate/controllers/course_detail_teacher/course_detail_teacher_controller.dart';
import 'package:classmate/models/authentication/user_model.dart';
import 'package:classmate/views/course_detail_teacher/widgets/assignment.dart';
import 'package:classmate/views/course_detail_teacher/widgets/assignment_card.dart';
import 'package:classmate/views/course_detail_teacher/widgets/course_card.dart';
import 'package:classmate/views/course_detail_teacher/widgets/custom_app_bar.dart';
import 'package:classmate/views/course_detail_teacher/widgets/not_found.dart';
import 'package:classmate/views/course_detail_teacher/widgets/student_list.dart';
import 'package:flutter/material.dart';

class CourseDetailScreen extends StatelessWidget {
  const CourseDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CourseDetailTeacherController _courseDetailTeacherController = CourseDetailTeacherController();



    final List<UserModel> students = [
      UserModel(id: "2007093", email: "iqbal@gmail.com", name: "iqbal", role: "student"),
      UserModel(id: "2007093", email: "iqbal@gmail.com", name: "iqbal", role: "student"),
      UserModel(id: "2007093", email: "iqbal@gmail.com", name: "iqbal", role: "student"),
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

    _courseDetailTeacherController.fetchCourseDetails('675c910186e75d98dc7c5cae',"A","Monday"); // Fetch details on load


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
          valueListenable: _courseDetailTeacherController.stateNotifier,
          builder: (context,state,child){
            if(state==CourseDetailState.loading){
              return const Center(child: CircularProgressIndicator());
            }
            else if(state==CourseDetailState.error){
              return Center(child: Text(_courseDetailTeacherController.errorMessage ?? 'Error occurred'));
            }
            else if(state == CourseDetailState.success && _courseDetailTeacherController.courseDetail != null){
              final course = _courseDetailTeacherController.courseDetail!;

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
                        assignments: assignments, // Pass the list of assignments here
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
