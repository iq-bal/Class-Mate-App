import 'package:classmate/utils/custom_app_bar.dart';
import 'package:classmate/views/course_overview_student/widgets/course_banner.dart';
import 'package:classmate/views/course_overview_student/widgets/course_reviews.dart';
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
  bool _showLessons = true; // Track which tab is selected

  @override
  void initState() {
    super.initState();
    _controller.getCourseOverview(widget.courseId);
    _controller.checkEnrollmentStatus(widget.courseId);
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
                          SectionHeader(
                            leftTitle: 'Lessons',
                            rightTitle: 'Reviews',
                            isLeftSelected: _showLessons,
                            onLeftTap: () {
                              setState(() {
                                _showLessons = true;
                              });
                            },
                            onRightTap: () {
                              setState(() {
                                _showLessons = false;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          _showLessons
                              ? ExpandableLessonList(
                                  lessons: course.syllabus.syllabus.entries.toList().asMap().entries.map((indexedEntry) => {
                                    'lessonNumber': indexedEntry.key + 1,
                                    'lessonTitle': indexedEntry.value.key,
                                    'duration': 'N/A',
                                    'isLocked': false,
                                    'topics': (indexedEntry.value.value as List<dynamic>)
                                        .map((topic) => topic.toString())
                                        .toList(),
                                  }).toList(),
                                )
                              : CourseReviews(reviews: course.reviews),
                          const SizedBox(height: 16),
                          ValueListenableBuilder(
                            valueListenable: _controller.stateNotifier,
                            builder: (context, CourseOverviewState enrollState, _) {
                              if (enrollState == CourseOverviewState.enrolling) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              
                              // Show status message if enrolled or if we have enrollment status
                              if (enrollState == CourseOverviewState.enrolled || _controller.enrollmentStatus != null) {
                                final status = _controller.enrollmentStatus?.status ?? 'Successfully enrolled';
                                final isApproved = status.toLowerCase() == 'approved';
                                
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: isApproved 
                                        ? [Colors.green.shade50, Colors.green.shade100]
                                        : [Colors.orange.shade50, Colors.orange.shade100],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 1,
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            isApproved ? Icons.check_circle : Icons.pending,
                                            color: isApproved ? Colors.green : Colors.orange,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Status: $status',
                                            style: TextStyle(
                                              color: isApproved ? Colors.green.shade800 : Colors.orange.shade800,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (_controller.enrollmentStatus?.enrolledAt != null)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 12.0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.calendar_today,
                                                color: Colors.grey,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Enrolled on: ${_controller.enrollmentStatus!.formattedDate}',
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ), 
                                    ],
                                  ),
                                );
                              }
                              
                              // Disable button if status is not 'Enroll' or if we're in enrolled state
                              final bool isEnrollButtonDisabled = 
                                  _controller.enrollButtonText != 'Enroll' || 
                                  enrollState == CourseOverviewState.enrolled;
                              
                              return GradientButton(
                                buttonText: _controller.enrollButtonText,
                                onPressed: isEnrollButtonDisabled 
                                    ? null 
                                    : () async {
                                        await _controller.enrollInCourse(widget.courseId);
                                        // Refresh the current page to show updated enrollment status
                                        if (mounted) {
                                          setState(() {
                                            // This will trigger a rebuild with the updated state
                                          });
                                        }
                                      },
                              );
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
