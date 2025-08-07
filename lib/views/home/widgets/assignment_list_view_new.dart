import 'package:flutter/material.dart';
import 'package:classmate/controllers/home/home_controller.dart';
import 'package:classmate/views/assignment/assignment_detail_view.dart';
import 'package:classmate/config/app_config.dart';
import 'package:intl/intl.dart';

class AssignmentListViewNew extends StatefulWidget {
  const AssignmentListViewNew({super.key});

  @override
  State<AssignmentListViewNew> createState() => _AssignmentListViewNewState();
}

class _AssignmentListViewNewState extends State<AssignmentListViewNew> {
  final HomeController _homeController = HomeController();
  List<dynamic> _assignments = [];
  List<dynamic> _filteredAssignments = [];
  bool _isLoading = true;
  String? _errorMessage;
  
  // Filter states
  String? _selectedCourse;
  String? _selectedStatus;
  DateTime? _selectedDate;
  bool _isFilterActive = false;

  @override
  void initState() {
    super.initState();
    _fetchAssignments();
  }

  Future<void> _fetchAssignments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _homeController.fetchAllAssignments();
      
      if (data != null && data['assignmentsForEnrolledCourses'] != null) {
        setState(() {
          _assignments = data['assignmentsForEnrolledCourses'] as List<dynamic>;
          _filteredAssignments = List.from(_assignments);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'No assignments found';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      print('Error fetching assignments: $e');
    }
  }

  String _formatDueDate(String? dateString) {
    if (dateString == null) return 'No deadline';
    
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = date.difference(now).inDays;
      
      if (difference < 0) {
        return 'Overdue';
      } else if (difference == 0) {
        return 'Due today';
      } else if (difference == 1) {
        return 'Due tomorrow';
      } else {
        return 'Due in $difference days';
      }
    } catch (e) {
      return 'Invalid date';
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM d\nyyyy').format(date);
    } catch (e) {
      return 'Invalid date';
    }
  }

  // Apply filters to assignments
  void _applyFilters() {
    setState(() {
      _isFilterActive = _selectedCourse != null || _selectedStatus != null || _selectedDate != null;
      
      _filteredAssignments = _assignments.where((assignment) {
        bool matchesCourse = true;
        bool matchesStatus = true;
        bool matchesDate = true;
        
        // Filter by course
        if (_selectedCourse != null) {
          final course = assignment['course'];
          matchesCourse = course['course_code'] == _selectedCourse || 
                         course['title'] == _selectedCourse;
        }
        
        // Filter by status
        if (_selectedStatus != null) {
          final status = _formatDueDate(assignment['deadline']);
          matchesStatus = status.toLowerCase().contains(_selectedStatus!.toLowerCase());
        }
        
        // Filter by date
        if (_selectedDate != null) {
          try {
            final deadline = DateTime.parse(assignment['deadline'] ?? '');
            matchesDate = deadline.year == _selectedDate!.year && 
                         deadline.month == _selectedDate!.month && 
                         deadline.day == _selectedDate!.day;
          } catch (e) {
            matchesDate = false;
          }
        }
        
        return matchesCourse && matchesStatus && matchesDate;
      }).toList();
    });
  }
  
  // Reset all filters
  void _resetFilters() {
    setState(() {
      _selectedCourse = null;
      _selectedStatus = null;
      _selectedDate = null;
      _filteredAssignments = List.from(_assignments);
      _isFilterActive = false;
    });
  }
  
  // Get unique course options from assignments
  List<String> _getCourseOptions() {
    final Set<String> courses = {};
    
    for (final assignment in _assignments) {
      final course = assignment['course'];
      if (course != null) {
        if (course['course_code'] != null) {
          courses.add(course['course_code']);
        }
        if (course['title'] != null) {
          courses.add(course['title']);
        }
      }
    }
    
    return courses.toList();
  }
  
  // Get status options
  List<String> _getStatusOptions() {
    return ['Overdue', 'Due today', 'Due tomorrow', 'Due in'];
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
        title: const Text('Assignments'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text('Error: $_errorMessage'))
              : Column(
                  children: [
                    // Filter Row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              FilterChipText(
                                'Filter',
                                isSelected: _isFilterActive,
                                onTap: () {
                                  if (_isFilterActive) {
                                    _resetFilters();
                                  } else {
                                    // Show filter options
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Filter Options'),
                                        content: const Text('Select filter options from the categories below.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('Close'),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                },
                              ),
                              FilterChipText(
                                'Date',
                                isSelected: _selectedDate != null,
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: _selectedDate ?? DateTime.now(),
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2030),
                                  );
                                  
                                  if (date != null) {
                                    setState(() {
                                      _selectedDate = date;
                                    });
                                    _applyFilters();
                                  }
                                },
                              ),
                              FilterChipText(
                                'Course',
                                isSelected: _selectedCourse != null,
                                onTap: () {
                                  final courses = _getCourseOptions();
                                  
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Select Course'),
                                      content: SizedBox(
                                        width: double.maxFinite,
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: courses.length,
                                          itemBuilder: (context, index) {
                                            return ListTile(
                                              title: Text(courses[index]),
                                              onTap: () {
                                                setState(() {
                                                  _selectedCourse = courses[index];
                                                });
                                                _applyFilters();
                                                Navigator.pop(context);
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Cancel'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              FilterChipText(
                                'Status',
                                isSelected: _selectedStatus != null,
                                onTap: () {
                                  final statuses = _getStatusOptions();
                                  
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Select Status'),
                                      content: SizedBox(
                                        width: double.maxFinite,
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: statuses.length,
                                          itemBuilder: (context, index) {
                                            return ListTile(
                                              title: Text(statuses[index]),
                                              onTap: () {
                                                setState(() {
                                                  _selectedStatus = statuses[index];
                                                });
                                                _applyFilters();
                                                Navigator.pop(context);
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Cancel'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          if (_isFilterActive)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Row(
                                children: [
                                  const Text('Active filters: ', style: TextStyle(fontSize: 12)),
                                  if (_selectedCourse != null)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 4.0),
                                      child: Chip(
                                        label: Text(_selectedCourse!, style: const TextStyle(fontSize: 10)),
                                        deleteIcon: const Icon(Icons.close, size: 12),
                                        onDeleted: () {
                                          setState(() {
                                            _selectedCourse = null;
                                          });
                                          _applyFilters();
                                        },
                                      ),
                                    ),
                                  if (_selectedStatus != null)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 4.0),
                                      child: Chip(
                                        label: Text(_selectedStatus!, style: const TextStyle(fontSize: 10)),
                                        deleteIcon: const Icon(Icons.close, size: 12),
                                        onDeleted: () {
                                          setState(() {
                                            _selectedStatus = null;
                                          });
                                          _applyFilters();
                                        },
                                      ),
                                    ),
                                  if (_selectedDate != null)
                                    Chip(
                                      label: Text(
                                        DateFormat('MMM d, yyyy').format(_selectedDate!),
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                      deleteIcon: const Icon(Icons.close, size: 12),
                                      onDeleted: () {
                                        setState(() {
                                          _selectedDate = null;
                                        });
                                        _applyFilters();
                                      },
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Assignment List
                    Expanded(
                      child: _filteredAssignments.isEmpty
                          ? const Center(child: Text('No assignments match the selected filters'))
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: _filteredAssignments.length,
                              itemBuilder: (context, index) {
                                final assignment = _filteredAssignments[index];
                                final course = assignment['course'];
                                final teacher = assignment['teacher'];
                                final user = teacher['user'];
                                
                                final status = _formatDueDate(assignment['deadline']);
                                final isOverdue = status.toLowerCase() == 'overdue';
                                
                                return AssignmentTile(
                                  item: AssignmentItem(
                                    status: status,
                                    date: _formatDate(assignment['deadline']),
                                    title: assignment['title'] ?? 'Untitled Assignment',
                                    subject: course['title'] ?? 'Unknown Course',
                                    course: course['course_code'] ?? '',
                                    instructor: user['name'] ?? 'Unknown Teacher',
                                    instructorImageUrl: user['profile_picture'] != null
                                        ? '${AppConfig.imageServer}${user['profile_picture']}'
                                        : 'https://i.pravatar.cc/100?img=1',
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AssignmentDetailPage(
                                          assignmentId: assignment['id'],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}

class FilterChipText extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  
  const FilterChipText(this.label, {super.key, this.isSelected = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade100 : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? Colors.blue : Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Text(
              label, 
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.grey, 
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            Icon(
              Icons.arrow_drop_down, 
              color: isSelected ? Colors.blue : Colors.grey,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class AssignmentTile extends StatelessWidget {
  final AssignmentItem item;
  final VoidCallback? onTap;
  const AssignmentTile({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isOverdue = item.status.toLowerCase() == 'overdue';
    final statusColor = isOverdue ? Colors.red[300] : Colors.green[400];

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Label
              Container(
                width: 28,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
                child: RotatedBox(
                  quarterTurns: -1,
                  child: Center(
                    child: Text(
                      item.status,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Date + Assignment Info
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date Column - Centered
                    SizedBox(
                      width: 50,
                      child: Center(
                        child: Text(
                          item.date,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.pinkAccent,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Assignment Card
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.subject,
                              style: const TextStyle(color: Colors.grey),
                            ),
                            Text(
                              item.course,
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundImage:
                                  NetworkImage(item.instructorImageUrl),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  item.instructor,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class AssignmentItem {
  final String status;
  final String date;
  final String title;
  final String subject;
  final String course;
  final String instructor;
  final String instructorImageUrl;

  AssignmentItem({
    required this.status,
    required this.date,
    required this.title,
    required this.subject,
    required this.course,
    required this.instructor,
    required this.instructorImageUrl,
  });
}
