import 'package:flutter/material.dart';
import 'package:classmate/controllers/course_detail_teacher/enrollment_controller.dart';
import 'package:classmate/models/course_detail_teacher/enrollment_model.dart';
import 'package:classmate/views/course_detail_teacher/widgets/enrollment_student_tile.dart';

class EnrollmentManagementView extends StatefulWidget {
  final String courseId;
  
  const EnrollmentManagementView({
    super.key,
    required this.courseId,
  });

  @override
  State<EnrollmentManagementView> createState() => _EnrollmentManagementViewState();
}

class _EnrollmentManagementViewState extends State<EnrollmentManagementView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final EnrollmentController _enrollmentController = EnrollmentController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchEnrollments();
  }

  void _fetchEnrollments() {
    _enrollmentController.fetchEnrollments(widget.courseId);
  }

  Future<void> _updateEnrollmentStatus(String enrollmentId, String status) async {
    try {
      final success = await _enrollmentController.updateEnrollmentStatus(
        enrollmentId,
        status,
        widget.courseId,
      );
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Student status updated to ${status.toUpperCase()}'),
            backgroundColor: status == 'approved' ? Colors.green : Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update student status'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _enrollmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Enrollments'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          tabs: const [
            Tab(text: 'Approved'),
            Tab(text: 'Pending'),
            Tab(text: 'Rejected'),
          ],
        ),
      ),
      body: ValueListenableBuilder<EnrollmentState>(
        valueListenable: _enrollmentController.stateNotifier,
        builder: (context, state, child) {
          if (state == EnrollmentState.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state == EnrollmentState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${_enrollmentController.errorMessage}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchEnrollments,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state == EnrollmentState.success) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildStudentList(_enrollmentController.approvedStudents),
                _buildStudentList(_enrollmentController.pendingStudents),
                _buildStudentList(_enrollmentController.rejectedStudents),
              ],
            );
          }
          return const Center(child: Text('No data available'));
        },
      ),
    );
  }

  Widget _buildStudentList(List<EnrollmentModel> enrollments) {
    if (enrollments.isEmpty) {
      return const Center(
        child: Text(
          'No students found',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: enrollments.length,
      itemBuilder: (context, index) {
        final enrollment = enrollments[index];
        return EnrollmentStudentTile(
          enrollment: enrollment,
          onTap: () {
            // Handle student tap if needed
            debugPrint('Tapped on student: ${enrollment.student.name}');
          },
          onStatusUpdate: (enrollmentId, status) {
            _updateEnrollmentStatus(enrollmentId, status);
          },
        );
      },
    );
  }
}