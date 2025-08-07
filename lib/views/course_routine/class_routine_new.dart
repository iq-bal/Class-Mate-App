import 'package:flutter/material.dart';
import 'dart:io';
import 'package:classmate/controllers/home/home_controller.dart';
import 'package:classmate/views/class_details_student/class_details_student_view.dart';
import 'package:url_launcher/url_launcher.dart';

class ClassRoutineNew extends StatefulWidget {
  const ClassRoutineNew({super.key});

  @override
  State<ClassRoutineNew> createState() => _ClassRoutineNewState();
}

class _ClassRoutineNewState extends State<ClassRoutineNew> {
  final HomeController _homeController = HomeController();
  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  final List<String> _shortDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  Map<String, List<dynamic>> _coursesByDay = {};
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedDay = '';
  int _selectedDayIndex = 0;

  @override
  void initState() {
    super.initState();
    // Set the initial selected day to the current day of the week
    final now = DateTime.now();
    _selectedDayIndex = now.weekday - 1; // 0 = Monday, 6 = Sunday
    if (_selectedDayIndex < 0 || _selectedDayIndex >= _days.length) {
      _selectedDayIndex = 0; // Default to Monday if something goes wrong
    }
    _selectedDay = _days[_selectedDayIndex];
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
    // Get current date
    final now = DateTime.now();
    final today = '${now.day} ${_getMonthName(now.month)}';
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Class Routine'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text('Error: $_errorMessage'))
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Row: Date + Add Reminder
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(today, style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                                SizedBox(height: 4),
                                Text(_selectedDay, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                // Create reminder URI for Android and iOS
                                final Uri reminderUri = Uri.parse(
                                  Platform.isAndroid
                                      ? 'content://com.android.calendar/time/'
                                      : 'calshow://'
                                );
                                
                                try {
                                  if (await canLaunchUrl(reminderUri)) {
                                    await launchUrl(reminderUri);
                                  } else {
                                    // Fallback for devices that don't support direct calendar launch
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Cannot open reminder app on this device')),
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error opening reminder app: $e')),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF00695C),
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: Text("+Add Reminder", style: TextStyle(fontSize: 16, color: Colors.white)),
                            ),
                          ],
                        ),

                        SizedBox(height: 16),

                        /// Days Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(_shortDays.length, (index) {
                            final isSelected = index == _selectedDayIndex;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedDayIndex = index;
                                  _selectedDay = _days[index];
                                });
                              },
                              child: Column(
                                children: [
                                  Text(_shortDays[index], 
                                    style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                                  if (isSelected)
                                    Container(
                                      margin: EdgeInsets.only(top: 4),
                                      height: 2,
                                      width: 20,
                                      color: Colors.teal,
                                    )
                                ],
                              ),
                            );
                          }),
                        ),

                        SizedBox(height: 20),

                        /// Time Slots
                        Expanded(
                          child: _buildTimeSlots(),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildTimeSlots() {
    final courses = _coursesByDay[_selectedDay] ?? [];
    
    if (courses.isEmpty) {
      return Center(child: Text('No classes scheduled for $_selectedDay'));
    }
    
    return ListView.builder(
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final courseData = courses[index];
        final course = courseData['course'];
        final schedule = courseData['schedule'];
        
        // Generate a color based on the course title
        final color = _getColorForCourse(course['title'] ?? '');
        
        return TimeSlotWidget(
          start: schedule['start_time'] ?? '',
          end: schedule['end_time'] ?? '',
          color: color,
          imagePath: 'assets/atom.png',
          courseTitle: course['title'] ?? 'Unknown Course',
          courseCode: course['course_code'] ?? '',
          roomNumber: schedule['room_number'] ?? 'TBA',
          section: schedule['section'] ?? '',
          teacherName: course['teacher']['name'] ?? course['teacher']['user_id']['email'] ?? 'Unknown',
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
        );
      },
    );
  }

  // Helper method to get month name
  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
  
  // Helper method to generate a color based on course title
  Color _getColorForCourse(String title) {
    // Simple hash function to generate a consistent color for the same title
    int hash = 0;
    for (var i = 0; i < title.length; i++) {
      hash = title.codeUnitAt(i) + ((hash << 5) - hash);
    }
    
    // Use the hash to generate a hue value between 0 and 360
    final hue = (hash % 360).abs().toDouble();
    
    // Create a color with the hue, using fixed saturation and lightness
    return HSLColor.fromAHSL(1.0, hue, 0.6, 0.7).toColor();
  }
}

class TimeSlotWidget extends StatelessWidget {
  final String start;
  final String end;
  final Color color;
  final String imagePath;
  final String courseTitle;
  final String courseCode;
  final String roomNumber;
  final String section;
  final String teacherName;
  final VoidCallback onTap;

  const TimeSlotWidget({
    super.key,
    required this.start,
    required this.end,
    required this.color,
    required this.imagePath,
    required this.courseTitle,
    required this.courseCode,
    required this.roomNumber,
    required this.section,
    required this.teacherName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Text(start, style: TextStyle(fontSize: 16)),
            Text(end, style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        SizedBox(width: 10),
        Column(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.teal, width: 2),
                color: Colors.white,
              ),
            ),
            Container(
              width: 2,
              height: 110,
              color: Colors.teal,
            )
          ],
        ),
        SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              margin: EdgeInsets.only(bottom: 16),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  /// Main card content
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.menu_book, size: 20, color: Colors.white),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              courseTitle,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (section.isNotEmpty)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text("Sec $section", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.home, size: 18, color: Colors.white),
                          SizedBox(width: 6),
                          Text("ROOM $roomNumber", style: TextStyle(color: Colors.white)),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.shield, size: 18, color: Colors.white),
                          SizedBox(width: 6),
                          Text(courseCode, style: TextStyle(color: Colors.white)),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.person, size: 18, color: Colors.white),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              teacherName,
                              style: TextStyle(color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  /// Atom Image – middle right
                  Positioned(
                    right: 0,
                    top: 30,
                    child: Image.asset(
                      imagePath,
                      width: 60,
                      height: 60,
                      fit: BoxFit.contain,
                    ),
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}