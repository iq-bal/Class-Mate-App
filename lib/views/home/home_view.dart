import 'package:classmate/views/assignment/assignment_detail_view.dart';
import 'package:classmate/views/assignment/assignment_list_view.dart';
import 'package:classmate/views/class_details_student/class_details_student_view.dart';
import 'package:classmate/views/course_routine/course_routine_view.dart';
import 'package:classmate/views/course_routine/class_routine_new.dart';
import 'package:classmate/views/home/widgets/assignment_list_view_new.dart';
import 'package:classmate/views/home/widgets/class_routine.dart';
import 'package:classmate/views/home/widgets/home_header.dart';
import 'package:classmate/views/home/widgets/next_class_card.dart';
import 'package:classmate/views/home/widgets/assignment_card.dart';
import 'package:classmate/views/home/widgets/class_test_card_new.dart';
import 'package:classmate/views/home/widgets/section_header.dart';
import 'package:classmate/controllers/home/home_controller.dart';
import 'package:classmate/models/home/home_page_model.dart';
import 'package:classmate/views/notification/notification_list_view.dart';
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
    // final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    print("---------------");
    final currentTime = "10:30";
    print("----------------");
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

  void _handleNotificationTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationListView(),
      ),
    );
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
    String? courseId;
    
    if (currentClassData != null && currentClassData['courses'] != null) {
      final courses = currentClassData['courses'] as List<dynamic>;
      if (courses.isNotEmpty) {
        final course = courses.first;
        currentClass = course['title'] ?? "No current class";
        courseId = course['_id'] ?? course['id'];
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
          courseId: courseId,
          onNotificationTap: _handleNotificationTap,
        ),

        const SizedBox(height: 16),

        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(title: "Next Classes", onSeeAll: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ClassRoutineNew(),
                    ),
                  );
                }),
                const SizedBox(height: 12),

                _buildNextClassesSection(),

                const SizedBox(height: 16),
                SectionHeader(
                  title: "Assignment", 
                  onSeeAll: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AssignmentListViewNew(),
                      ),
                    );
                  },
                ),
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
        
        // Calculate due text based on the date
        String dueText = _formatDueDate(classTest.date);
        
        // Convert duration string to int for minutes
        int durationMin = 0;
        try {
          durationMin = int.parse(classTest.duration);
        } catch (e) {
          // If parsing fails, use 0 as default
          print('Failed to parse duration: ${classTest.duration}');
        }
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ClassTestCard(
            subject: courseTitle,
            title: classTest.title,
            description: classTest.description,
            durationMin: durationMin,
            points: classTest.totalMarks,
            dueText: dueText,
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
      DateTime testDate;
      
      // Check if the date is a timestamp (numeric string)
      if (RegExp(r'^\d+$').hasMatch(date)) {
        // Convert timestamp to DateTime
        final timestamp = int.parse(date);
        testDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
      } else {
        // Parse as regular date string
        testDate = DateTime.parse(date);
      }
      
      final now = DateTime.now();
      final difference = testDate.difference(now).inDays;
      
      // Format the date nicely
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                     'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final formattedDate = '${testDate.day} ${months[testDate.month - 1]}';
      
      if (difference == 0) {
        return 'Today';
      } else if (difference == 1) {
        return 'Tomorrow';
      } else if (difference > 1 && difference <= 7) {
        return formattedDate;
      } else if (difference > 7) {
        return formattedDate;
      } else {
        return 'Past';
      }
    } catch (e) {
      return 'Invalid Date';
    }
  }
  
  Color _getDateColor(String date) {
    try {
      DateTime testDate;
      
      // Check if the date is a timestamp (numeric string)
      if (RegExp(r'^\d+$').hasMatch(date)) {
        // Convert timestamp to DateTime
        final timestamp = int.parse(date);
        testDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
      } else {
        // Parse as regular date string
        testDate = DateTime.parse(date);
      }
      
      final now = DateTime.now();
      final difference = testDate.difference(now).inDays;
      
      if (difference < 0) {
        return Colors.red.shade600; // Past due
      } else if (difference == 0) {
        return Colors.red.shade600; // Today
      } else if (difference <= 3) {
        return Colors.orange.shade600; // Within 3 days
      } else if (difference <= 7) {
        return Colors.blue.shade600; // Within a week
      } else {
        return Colors.green.shade600; // Future
      }
    } catch (e) {
      return Colors.grey.shade600;
    }
  }
  
  Color _getDateBackgroundColor(String date) {
    try {
      DateTime testDate;
      
      // Check if the date is a timestamp (numeric string)
      if (RegExp(r'^\d+$').hasMatch(date)) {
        // Convert timestamp to DateTime
        final timestamp = int.parse(date);
        testDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
      } else {
        // Parse as regular date string
        testDate = DateTime.parse(date);
      }
      
      final now = DateTime.now();
      final difference = testDate.difference(now).inDays;
      
      if (difference < 0) {
        return Colors.red.shade50; // Past due
      } else if (difference == 0) {
        return Colors.red.shade50; // Today
      } else if (difference <= 3) {
        return Colors.orange.shade50; // Within 3 days
      } else if (difference <= 7) {
        return Colors.blue.shade50; // Within a week
      } else {
        return Colors.green.shade50; // Future
      }
    } catch (e) {
      return Colors.grey.shade100;
    }
  }
}
