import 'package:classmate/utils/custom_app_bar.dart';
import 'package:classmate/views/course_overview_student/widgets/course_banner.dart';
import 'package:classmate/views/course_overview_student/widgets/expandable_lesson_list.dart';
import 'package:classmate/views/course_overview_student/widgets/gradient_button.dart';
import 'package:classmate/views/course_overview_student/widgets/instructor_info.dart';
import 'package:classmate/views/course_overview_student/widgets/section_header.dart';
import 'package:classmate/controllers/course_overview/course_overview_controller.dart';
import 'package:flutter/material.dart';

class CourseOverviewView extends StatefulWidget {
  final String courseId;

  const CourseOverviewView({super.key, required this.courseId});

  @override
  State<CourseOverviewView> createState() => _CourseOverviewViewState();
}

class _CourseOverviewViewState extends State<CourseOverviewView> {
  final CourseOverviewController _controller = CourseOverviewController();

  @override
  void initState() {
    super.initState();
    _controller.getCourseOverview(widget.courseId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: _controller.stateNotifier,
          builder: (context, CourseOverviewState state, _) {
            if (state == CourseOverviewState.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state == CourseOverviewState.error) {
              return Center(child: Text(_controller.errorMessage ?? 'An error occurred'));
            }

            if (state == CourseOverviewState.success && _controller.courseOverview != null) {
              final course = _controller.courseOverview!;
              return Column(
                children: [
                  CustomAppBar(
                    title: "Course Details",
                    onBackPress: () {
                      Navigator.pop(context);
                    },
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CourseBanner(
                            title: course.title,
                            description: course.description,
                          ),
                          const SizedBox(height: 16),
                          InstructorInfo(
                            instructorName: course.teacher.userId.name,
                            imageUrl: course.teacher.userId.profilePicture,
                            rating: course.averageRating.toString(),
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
                            lessons: course.syllabus.syllabus.entries.toList().asMap().entries.map((indexedEntry) => {
                              'lessonNumber': indexedEntry.key + 1,
                              'lessonTitle': indexedEntry.value.key,
                              'duration': 'N/A',
                              'isLocked': false,
                              'topics': (indexedEntry.value.value as List<dynamic>)
                                  .map((topic) => topic.toString())
                                  .toList(),
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                          GradientButton(
                            buttonText: 'Enroll',
                            onPressed: () {
                              // TODO: Implement enrollment functionality
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            return const Center(child: Text('No course data available'));
          },
        ),
      ),
    );
  }
}
