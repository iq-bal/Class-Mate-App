import 'package:flutter/material.dart';
import 'package:classmate/controllers/home/home_controller.dart';
import 'package:classmate/views/assignment/assignment_detail_view.dart';
import 'package:classmate/config/app_config.dart';
import 'package:intl/intl.dart';

class AssignmentListView extends StatefulWidget {
  const AssignmentListView({super.key});

  @override
  State<AssignmentListView> createState() => _AssignmentListViewState();
}

class _AssignmentListViewState extends State<AssignmentListView> {
  final HomeController _homeController = HomeController();
  List<dynamic> _assignments = [];
  bool _isLoading = true;
  String? _errorMessage;

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

  Color _getDeadlineColor(String? dateString) {
    if (dateString == null) return Colors.grey;
    
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = date.difference(now).inDays;
      
      if (difference < 0) {
        return Colors.red;
      } else if (difference <= 1) {
        return Colors.orange;
      } else if (difference <= 3) {
        return Colors.amber;
      } else {
        return Colors.green;
      }
    } catch (e) {
      return Colors.grey;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM d, yyyy').format(date);
    } catch (e) {
      return 'Invalid date';
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
        title: const Text('All Assignments'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text('Error: $_errorMessage'))
              : _buildAssignmentsList(),
    );
  }

  Widget _buildAssignmentsList() {
    if (_assignments.isEmpty) {
      return const Center(child: Text('No assignments available'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _assignments.length,
      itemBuilder: (context, index) {
        final assignment = _assignments[index];
        final course = assignment['course'];
        final teacher = assignment['teacher'];
        final user = teacher['user'];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          elevation: 2,
          child: InkWell(
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
                          assignment['title'] ?? 'Untitled Assignment',
                          style: const TextStyle(
                            fontSize: 18,
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
                  Text(
                    course['title'] ?? 'Unknown Course',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (assignment['description'] != null)
                    Text(
                      assignment['description'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: _getDeadlineColor(assignment['deadline']),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDueDate(assignment['deadline']),
                        style: TextStyle(
                          fontSize: 14,
                          color: _getDeadlineColor(assignment['deadline']),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        _formatDate(assignment['deadline']),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundImage: user['profile_picture'] != null
                            ? NetworkImage('${AppConfig.imageServer}${user['profile_picture']}')
                            : null,
                        child: user['profile_picture'] == null
                            ? const Icon(Icons.person, size: 16)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'By ${user['name'] ?? 'Unknown Teacher'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Created: ${_formatDate(assignment['created_at'])}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}