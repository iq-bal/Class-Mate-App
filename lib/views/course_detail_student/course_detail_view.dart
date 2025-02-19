import 'package:classmate/utils/custom_app_bar.dart';
import 'package:classmate/views/course_detail_student/widgets/course_banner.dart';
import 'package:classmate/views/course_detail_student/widgets/expandable_lesson_list.dart';
import 'package:classmate/views/course_detail_student/widgets/gradient_button.dart';
import 'package:classmate/views/course_detail_student/widgets/instructor_info.dart';
import 'package:classmate/views/course_detail_student/widgets/section_header.dart';
import 'package:flutter/material.dart';

import '../../controllers/course_detail_student/course_detail_student_controller.dart';

class CourseDetailScreen extends StatefulWidget {
  final String courseId; // Accept courseId as a parameter
  const CourseDetailScreen({super.key, required this.courseId});

  @override
  _CourseDetailScreenState createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  late CourseDetailStudentController courseDetailStudentController;

  @override
  void initState() {
    super.initState();
    courseDetailStudentController = CourseDetailStudentController();
    courseDetailStudentController.getCourseDetailsAndSyllabuses(widget.courseId);
  }

  // Method to reload course details after enrollment
  void reloadCourseDetails() {
    courseDetailStudentController.getCourseDetailsAndSyllabuses(widget.courseId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              title: "Course Details",
              onBackPress: () {
                Navigator.pop(context);
              },
            ),
            Expanded(
              child: ValueListenableBuilder<CourseDetailStudentState>(
                valueListenable: courseDetailStudentController.stateNotifier,
                builder: (context, state, _) {
                  if (state == CourseDetailStudentState.loading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state == CourseDetailStudentState.error) {
                    return Center(
                      child: Text(
                        courseDetailStudentController.errorMessage ?? 'An error occurred',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  } else if (state == CourseDetailStudentState.success) {
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CourseBanner(
                            title: courseDetailStudentController.courseDetail?.title ?? 'No Title',
                            description: courseDetailStudentController.courseDetail?.description ?? 'No Description',
                          ),
                          const SizedBox(height: 16),
                          InstructorInfo(
                            instructorName: courseDetailStudentController.courseDetail?.teacherEntity.name ?? 'Unknown Instructor',
                            imageUrl: 'https://via.placeholder.com/150',
                            rating: '4.9 (1.2k)',
                          ),
                          const SizedBox(height: 16),
                          const SectionHeader(
                            leftTitle: 'Lessons',
                            rightTitle: 'Reviews',
                            leftTextStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            rightTextStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ExpandableLessonList(
                            lessons: courseDetailStudentController.courseDetail?.syllabusEntity.syllabus?.entries
                                .toList()
                                .asMap()
                                .map((index, entry) {
                              return MapEntry(
                                index,
                                {
                                  'lessonNumber': index + 1,
                                  'lessonTitle': entry.key,
                                  'duration': 'N/A',
                                  'isLocked': false,
                                  'topics': entry.value,
                                },
                              );
                            })
                                .values
                                .toList() ??
                                [],
                          ),
                          const SizedBox(height: 16),
                          GradientButton(
                            buttonText: courseDetailStudentController.courseDetail?.enrollmentStatus ?? 'Enroll',
                            onPressed: courseDetailStudentController.courseDetail?.enrollmentStatus == null
                                ? () async {
                              await courseDetailStudentController.enrollInCourse("675c910186e75d98dc7c5cae");
                              reloadCourseDetails();
                            }
                                : null,
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink(); // Return an empty widget if the state isn't handled
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
