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
        title: const Text(
          'Assignments', 
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 24,
            letterSpacing: 0.5,
        ),
      ),
        backgroundColor: const Color(0xFF3D5AFE),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
        ),
      ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 26),
            onPressed: () => _fetchAssignments(),
            tooltip: 'Refresh Assignments',
        ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3D5AFE), Color(0xFF536DFE)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
          ),
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30),
          ),
        ),
      ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF3D5AFE).withOpacity(0.15),
              const Color(0xFF3D5AFE).withOpacity(0.05),
              Colors.white,
            ],
            stops: const [0.0, 0.3, 1.0],
        ),
      ),
        child: _isLoading
          ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3D5AFE)),
              ),
              )
          : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          color: Colors.red[400],
                          size: 60,
                      ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                        ),
                          textAlign: TextAlign.center,
                      ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _fetchAssignments,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try Again'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3D5AFE),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      ],
                  ),
                  )
              : Column(
                  children: [
                    // Filter Row
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                        ),
                        ],
                    ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              'Filter Assignments',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF3D5AFE),
                            ),
                          ),
                        ),
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
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        shape: BoxShape.circle,
                                    ),
                                      child: Icon(
                                        Icons.assignment_outlined,
                                        size: 60,
                                        color: const Color(0xFF3D5AFE),
                                    ),
                                  ),
                                    const SizedBox(height: 24),
                                    const Text(
                                      'No Assignments Found',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF333333),
                                    ),
                                  ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _isFilterActive
                                          ? 'Try changing your filter settings'
                                          : 'You don\'t have any assignments yet',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey.shade600,
                                    ),
                                  ),
                                    const SizedBox(height: 24),
                                    if (_isFilterActive)
                                      ElevatedButton.icon(
                                        onPressed: _resetFilters,
                                        icon: const Icon(Icons.filter_alt_off),
                                        label: const Text('Reset Filters'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF3D5AFE),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(30),
                                        ),
                                      ),
                                    ),
                                  ],
                              ),
                              )
                            : Column(
                                children: [
                                  // Assignment Count Header
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF3D5AFE).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                        ),
                                          child: const Icon(
                                            Icons.assignment_rounded,
                                            color: Color(0xFF3D5AFE),
                                            size: 20,
                                        ),
                                      ),
                                        const SizedBox(width: 12),
                                        Text(
                                          '${_filteredAssignments.length} ${_filteredAssignments.length == 1 ? 'Assignment' : 'Assignments'}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF333333),
                                        ),
                                      ),
                                      ],
                                  ),
                                ),
                                  
                                  // Assignment List
                                  Expanded(
                                    child: ListView.builder(
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
                          ),
                          ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF3D5AFE), Color(0xFF536DFE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.shade300,
            width: 1.5,
        ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF3D5AFE).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : null,
      ),
        child: Row(
          children: [
            Text(
              label, 
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700, 
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                letterSpacing: 0.3,
            ),
          ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down, 
              color: isSelected ? Colors.white : Colors.grey.shade600,
              size: 20,
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
    final isDueToday = item.status.toLowerCase() == 'due today';
    final isDueTomorrow = item.status.toLowerCase() == 'due tomorrow';
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 5),
                spreadRadius: 1,
            ),
            ],
            border: Border.all(color: Colors.grey.shade100, width: 1),
        ),
          child: Column(
            children: [
              // Header with status indicator
              Container(
                height: 8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isOverdue
                        ? [Colors.red.shade700, Colors.red.shade400]
                        : isDueToday
                            ? [Colors.orange.shade700, Colors.orange.shade400]
                            : isDueTomorrow
                                ? [Colors.blue.shade700, Colors.blue.shade400]
                                : [Colors.green.shade700, Colors.green.shade400],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                ),
              ),
            ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date Column
                    Container(
                      width: 70,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                        ),
                        ],
                    ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 18,
                            color: isOverdue
                                ? Colors.red.shade700
                                : isDueToday
                                    ? Colors.orange.shade700
                                    : isDueTomorrow
                                        ? Colors.blue.shade700
                                        : Colors.green.shade700,
                        ),
                          const SizedBox(height: 6),
                          Text(
                            item.date,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade800,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                          ),
                        ),
                        ],
                    ),
                  ),

                    const SizedBox(width: 16),

                    // Assignment Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Course and Status
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Course code
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF3D5AFE), Color(0xFF536DFE)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF3D5AFE).withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                  ),
                                  ],
                              ),
                                child: Text(
                                  item.course,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    letterSpacing: 0.5,
                                ),
                              ),
                            ),
                              
                              // Status pill
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isOverdue
                                      ? Colors.red.shade100
                                      : isDueToday
                                          ? Colors.orange.shade100
                                          : isDueTomorrow
                                              ? Colors.blue.shade100
                                              : Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(20),
                              ),
                                child: Text(
                                  item.status,
                                  style: TextStyle(
                                    color: isOverdue
                                        ? Colors.red.shade800
                                        : isDueToday
                                            ? Colors.orange.shade800
                                            : isDueTomorrow
                                                ? Colors.blue.shade800
                                                : Colors.green.shade800,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                ),
                              ),
                            ),
                            ],
                        ),
                          
                          const SizedBox(height: 12),
                          
                          // Title
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xFF333333),
                          ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                        ),
                          
                          const SizedBox(height: 4),
                          
                          // Subject
                          Text(
                            item.subject,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 14,
                          ),
                        ),
                          
                          const SizedBox(height: 16),
                          
                          // Instructor
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 3,
                                      offset: const Offset(0, 1),
                                  ),
                                  ],
                              ),
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundImage: NetworkImage(item.instructorImageUrl),
                              ),
                            ),
                              const SizedBox(width: 10),
                              Text(
                                item.instructor,
                                style: const TextStyle(
                                  color: Color(0xFF555555),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                              ),
                            ),
                            ],
                        ),
                        ],
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
