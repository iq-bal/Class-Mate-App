import 'package:classmate/controllers/course_detail_student/course_detail_student_controller.dart';
import 'package:classmate/views/course_detail_student/widgets/course_banner.dart';
import 'package:classmate/views/course_detail_student/widgets/expandable_lesson_list.dart';
import 'package:classmate/views/course_detail_student/widgets/gradient_button.dart';
import 'package:classmate/views/course_detail_student/widgets/instructor_info.dart';
import 'package:classmate/views/course_detail_student/widgets/section_header.dart';
import 'package:flutter/material.dart';

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
      appBar: AppBar(
        title: const Text(
          'Course Details',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: ValueListenableBuilder<CourseDetailStudentState>(
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
                        index, // This will be used as the lesson number
                        {
                          'lessonNumber': index + 1,  // Module number starts from 1
                          'lessonTitle': entry.key,   // Module name as the lesson title
                          'duration': 'N/A',          // Placeholder for duration
                          'isLocked': false,          // Set your logic for locked lessons
                          'topics': entry.value,      // List of topics (subtopics for each module)
                        },
                      );
                    })
                        .values
                        .toList() ?? [],
                  ),
                  const SizedBox(height: 16),

                  GradientButton(
                    buttonText: courseDetailStudentController.courseDetail?.enrollmentStatus ?? 'Enroll',  // Default to "Enroll" if status is null
                    onPressed: courseDetailStudentController.courseDetail?.enrollmentStatus == null
                        ? () async {
                      await courseDetailStudentController.enrollInCourse("675c910186e75d98dc7c5cae");
                      reloadCourseDetails();  // Reload the course details after enrollment
                    }
                        : null,  // If status is not null, make the button unclickable
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink(); // Return an empty widget if the state isn't handled
        },
      ),
    );
  }
}
