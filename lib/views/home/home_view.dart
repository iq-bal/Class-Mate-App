import 'package:classmate/views/assignment/assignment_detail_view.dart';
import 'package:classmate/views/class_details_student/class_details_student_view.dart';
import 'package:classmate/views/home/widgets/home_header.dart';
import 'package:classmate/views/home/widgets/next_class_card.dart';
import 'package:classmate/views/home/widgets/assignment_card.dart';
import 'package:classmate/views/home/widgets/class_test_card.dart';
import 'package:classmate/views/home/widgets/section_header.dart';
import 'package:classmate/controllers/home/home_controller.dart';
import 'package:classmate/models/home/home_page_model.dart';
import 'package:flutter/material.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final HomeController _homeController = HomeController();

  @override
  void initState() {
    super.initState();
    _fetchHomeData();
  }

  Future<void> _fetchHomeData() async {
    print('DEBUG: Starting _fetchHomeData');
    
    // Get current day and time
    final now = DateTime.now();
    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final currentDay = dayNames[now.weekday - 1];
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    print('DEBUG: Current day: $currentDay, Current time: $currentTime');
    
    // Fetch current class for HomeHeader
    await _homeController.fetchCurrentClass(currentDay, currentTime);
    print('DEBUG: Finished fetching current class');
    
    // Fetch today's enrolled courses for the next classes section
    await _homeController.fetchTodaysEnrolledCourses(currentDay);
    print('DEBUG: Finished fetching today\'s courses');
    
    // Fetch all student assignments for the assignments section
    await _homeController.fetchStudentAllAssignments();
    print('DEBUG: Finished fetching assignments');
    
    // Fetch all student class tests for the class tests section
    await _homeController.fetchStudentAllClassTests();
    print('DEBUG: Finished fetching class tests');
    
    // Check assignments data immediately after fetch
    if (_homeController.assignmentsData != null) {
      print('DEBUG: Assignments data is available with ${_homeController.assignmentsData!.enrollments.length} enrollments');
    } else {
      print('DEBUG: Assignments data is still null after fetch');
    }
    
    // Force UI rebuild after all data fetches
    if (mounted) {
      setState(() {
        print('DEBUG: setState called to rebuild UI');
      });
    }
  }

  @override
  void dispose() {
    _homeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ValueListenableBuilder<HomeState>(
        valueListenable: _homeController.stateNotifier,
        builder: (context, state, child) {
          if (state == HomeState.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state == HomeState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${_homeController.errorMessage}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _homeController.fetchHomePageData(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state == HomeState.success && _homeController.homePageData != null) {
            return _buildHomeContent();
          }
          return const Center(child: Text('No data available'));
        },
      ),
    );
  }

  Widget _buildHomeContent() {
    final user = _homeController.user;
    final currentClassData = _homeController.currentClassData;
    
    // Extract current class and instructor from the new data structure
    String currentClass = "No current class";
    String currentInstructor = "No instructor";
    
    if (currentClassData != null && currentClassData['courses'] != null) {
      final courses = currentClassData['courses'] as List<dynamic>;
      if (courses.isNotEmpty) {
        final course = courses.first;
        currentClass = course['title'] ?? "No current class";
        if (course['teacher'] != null && course['teacher']['user_id'] != null) {
          currentInstructor = course['teacher']['user_id']['name'] ?? "No instructor";
        }
      }
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeHeader(
          userName: user?.name ?? "Student",
          currentClass: currentClass,
          currentInstructor: currentInstructor,
          onJoinClass: () => print("Joining class..."),
          onNotificationTap: () => print("Notification clicked"),
        ),

        const SizedBox(height: 16),

        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(title: "Next Classes", onSeeAll: () {}),
                const SizedBox(height: 12),

                _buildNextClassesSection(),

                const SizedBox(height: 16),
                SectionHeader(title: "Assignment", onSeeAll: () {}),
                const SizedBox(height: 12),

                _buildAssignmentsSection(),

                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "Class Tests",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                _buildClassTestsSection(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNextClassesSection() {
    final schedules = _homeController.allSchedules;
    
    if (schedules.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text('No classes today'),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: schedules.take(5).map((schedule) {
          final course = _homeController.getCourseForSchedule(schedule);
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: NextClassCard(
              title: course?.title ?? 'Unknown Course',
              teacherName: course?.teacher.userId.name ?? 'Unknown Teacher',
              timeRange: '${schedule.startTime} - ${schedule.endTime}',
              icon: Icons.school,
              onTap: () {
                if (course != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClassDetailsStudent(
                        courseId: course.id,
                        day: schedule.day,
                        teacherId: course.teacher.id,
                      ),
                    ),
                  );
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAssignmentsSection() {
    // Direct access to assignments data
    if (_homeController.assignmentsData == null) {
      print('DEBUG: assignmentsData is null');
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text('Loading assignments...'),
      );
    }
    
    print('DEBUG: assignmentsData has ${_homeController.assignmentsData!.enrollments.length} enrollments');
    
    // Collect all assignments with their course info
    List<Map<String, dynamic>> assignmentsWithCourse = [];
    
    for (final enrollment in _homeController.assignmentsData!.enrollments) {
      print('DEBUG: enrollment status: ${enrollment.status}');
      if (enrollment.status.toLowerCase() == 'approved') {
        for (final course in enrollment.courses) {
          print('DEBUG: course ${course.title} has ${course.assignments.length} assignments');
          for (final assignment in course.assignments) {
            assignmentsWithCourse.add({
              'assignment': assignment,
              'courseTitle': course.title,
            });
          }
        }
      }
    }
    
    print('DEBUG: Total assignments found: ${assignmentsWithCourse.length}');
    
    if (assignmentsWithCourse.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text('No assignments available'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: assignmentsWithCourse.length,
      itemBuilder: (context, index) {
        final item = assignmentsWithCourse[index];
        final assignment = item['assignment'] as AssignmentHomeModel;
        final courseTitle = item['courseTitle'] as String;
        
        return AssignmentCard(
          title: assignment.title,
          subject: courseTitle,
          dueText: _formatDueDate(assignment.deadline),
          onViewTask: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AssignmentDetailPage(assignmentId: assignment.id),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildClassTestsSection() {
    // Direct access to class tests data
    if (_homeController.classTestsData == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text('Loading class tests...'),
      );
    }
    
    // Collect all class tests with their course info
    List<Map<String, dynamic>> classTestsWithCourse = [];
    
    for (final enrollment in _homeController.classTestsData!.enrollments) {
      if (enrollment.status.toLowerCase() == 'approved') {
        for (final course in enrollment.courses) {
          for (final classTest in course.classTests) {
            classTestsWithCourse.add({
              'classTest': classTest,
              'courseTitle': course.title,
            });
          }
        }
      }
    }
    
    if (classTestsWithCourse.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text('No class tests available'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: classTestsWithCourse.length,
      itemBuilder: (context, index) {
        final item = classTestsWithCourse[index];
        final classTest = item['classTest'] as ClassTestHomeModel;
        final courseTitle = item['courseTitle'] as String;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  classTest.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Course: $courseTitle',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                if (classTest.description.isNotEmpty)
                  Text(
                    classTest.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      _formatClassTestDate(classTest.date),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${classTest.duration} min',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.grade, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${classTest.totalMarks} marks',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDueDate(String deadline) {
    try {
      final date = DateTime.parse(deadline);
      final now = DateTime.now();
      final difference = date.difference(now).inDays;
      
      if (difference == 0) {
        return 'Due today';
      } else if (difference == 1) {
        return 'Due tomorrow';
      } else if (difference > 1) {
        return 'Due in $difference days';
      } else {
        return 'Overdue';
      }
    } catch (e) {
      return deadline;
    }
  }
  
  String _formatClassTestDate(String date) {
    try {
      final testDate = DateTime.parse(date);
      final now = DateTime.now();
      final difference = testDate.difference(now).inDays;
      
      if (difference == 0) {
        return 'Today';
      } else if (difference == 1) {
        return 'Tomorrow';
      } else if (difference > 1) {
        return 'In $difference days';
      } else {
        return 'Past';
      }
    } catch (e) {
      return date;
    }
  }
}
