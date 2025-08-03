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
        
        return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 4,
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Title and Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                     child: Text(
                       classTest.title,
                       style: const TextStyle(
                         fontSize: 20,
                         fontWeight: FontWeight.w700,
                         color: Color(0xFF1A1A1A),
                         letterSpacing: -0.5,
                       ),
                     ),
                   ),
                   Container(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "Test",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue[800],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Course Title
               Container(
                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                 decoration: BoxDecoration(
                   color: Colors.blue.shade50,
                   borderRadius: BorderRadius.circular(12),
                   border: Border.all(color: Colors.blue.shade100),
                 ),
                 child: Text(
                   courseTitle,
                   style: TextStyle(
                     fontSize: 14,
                     color: Colors.blue.shade700,
                     fontWeight: FontWeight.w600,
                     letterSpacing: 0.2,
                   ),
                 ),
               ),
               
               if (classTest.description.isNotEmpty) ...[
                 const SizedBox(height: 12),
                 Text(
                   classTest.description,
                   style: TextStyle(
                     fontSize: 15,
                     color: Colors.grey[700],
                     height: 1.5,
                     fontWeight: FontWeight.w400,
                   ),
                   maxLines: 2,
                   overflow: TextOverflow.ellipsis,
                 ),
               ],
              
              const SizedBox(height: 16),
              
              // Info Row with Icons
               Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   // Date Info
                   Expanded(
                     child: Row(
                       children: [
                         Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _getDateBackgroundColor(classTest.date),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: _getDateColor(classTest.date),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              _formatClassTestDate(classTest.date),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _getDateColor(classTest.date),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                       ],
                     ),
                   ),
                   
                   // Duration Info
                   Expanded(
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         Container(
                           padding: const EdgeInsets.all(8),
                           decoration: BoxDecoration(
                             color: Colors.grey.shade100,
                             borderRadius: BorderRadius.circular(8),
                           ),
                           child: Icon(
                             Icons.timer,
                             size: 16,
                             color: Colors.grey.shade600,
                           ),
                         ),
                         const SizedBox(width: 8),
                         Text(
                           '${classTest.duration}m',
                           style: TextStyle(
                             fontSize: 13,
                             fontWeight: FontWeight.w500,
                             color: Colors.black.withOpacity(0.7),
                           ),
                         ),
                       ],
                     ),
                   ),
                   
                   // Marks Info
                   Expanded(
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.end,
                       children: [
                         Container(
                           padding: const EdgeInsets.all(8),
                           decoration: BoxDecoration(
                             color: Colors.grey.shade100,
                             borderRadius: BorderRadius.circular(8),
                           ),
                           child: Icon(
                             Icons.grade,
                             size: 16,
                             color: Colors.grey.shade600,
                           ),
                         ),
                         const SizedBox(width: 8),
                         Text(
                           '${classTest.totalMarks}pts',
                           style: TextStyle(
                             fontSize: 13,
                             fontWeight: FontWeight.w500,
                             color: Colors.black.withOpacity(0.7),
                           ),
                         ),
                       ],
                     ),
                   ),
                 ],
               ),
            ],
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
