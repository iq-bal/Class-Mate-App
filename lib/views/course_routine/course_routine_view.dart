import 'package:flutter/material.dart';
import 'package:classmate/controllers/home/home_controller.dart';
import 'package:classmate/views/class_details_student/class_details_student_view.dart';

class CourseRoutineView extends StatefulWidget {
  const CourseRoutineView({super.key});

  @override
  State<CourseRoutineView> createState() => _CourseRoutineViewState();
}

class _CourseRoutineViewState extends State<CourseRoutineView> {
  final HomeController _homeController = HomeController();
  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  Map<String, List<dynamic>> _coursesByDay = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchEnrolledCourses();
  }

  Future<void> _fetchEnrolledCourses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _homeController.fetchAllEnrolledCourses();
      
      if (data != null && data['myApprovedEnrollments'] != null) {
        // Initialize empty lists for each day
        for (final day in _days) {
          _coursesByDay[day] = [];
        }

        // Process enrollments and organize courses by day
        final enrollments = data['myApprovedEnrollments'] as List<dynamic>;
        
        for (final enrollment in enrollments) {
          if (enrollment['courses'] != null) {
            final courses = enrollment['courses'] as List<dynamic>;
            
            for (final course in courses) {
              if (course['schedules'] != null) {
                final schedules = course['schedules'] as List<dynamic>;
                
                for (final schedule in schedules) {
                  final day = schedule['day'];
                  if (_coursesByDay.containsKey(day)) {
                    _coursesByDay[day]!.add({
                      'course': course,
                      'schedule': schedule,
                    });
                  }
                }
              }
            }
          }
        }

        // Sort courses by start time for each day
        for (final day in _days) {
          _coursesByDay[day]!.sort((a, b) {
            final aTime = a['schedule']['start_time'];
            final bTime = b['schedule']['start_time'];
            return aTime.compareTo(bTime);
          });
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      print('Error fetching enrolled courses: $e');
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
      appBar: AppBar(
        title: const Text('Course Routine'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text('Error: $_errorMessage'))
              : _buildRoutineContent(),
    );
  }

  Widget _buildRoutineContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _days.map((day) {
            return _buildDaySection(day);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDaySection(String day) {
    final courses = _coursesByDay[day] ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            day,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        courses.isEmpty
            ? const Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Text('No classes scheduled'),
              )
            : Column(
                children: courses.map((courseData) {
                  final course = courseData['course'];
                  final schedule = courseData['schedule'];
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    elevation: 2,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ClassDetailsStudent(
                              courseId: course['id'],
                              day: schedule['day'],
                              teacherId: course['teacher']['id'],
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    course['title'] ?? 'Unknown Course',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                    vertical: 4.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  child: Text(
                                    course['course_code'] ?? '',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${schedule['start_time']} - ${schedule['end_time']}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Room: ${schedule['room_number'] ?? 'TBA'}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.person,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Teacher: ${course['teacher']['name'] ?? course['teacher']['user_id']['email'] ?? 'Unknown'}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            if (schedule['section'] != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.group,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Section: ${schedule['section']}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
        const Divider(),
      ],
    );
  }
}