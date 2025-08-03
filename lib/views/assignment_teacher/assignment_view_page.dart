import 'package:classmate/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'pdf_viewer_page.dart';
import 'evaluation_page.dart';
import 'package:classmate/controllers/assignment_teacher/assignment_teacher_controller.dart';
import 'package:intl/intl.dart'; // For date formatting

class AssignmentViewPage extends StatefulWidget {
  final String assignmentId;
  const AssignmentViewPage({super.key, required this.assignmentId});

  @override
  State<AssignmentViewPage> createState() => _AssignmentViewPageState();
}

class _AssignmentViewPageState extends State<AssignmentViewPage> {
  final AssignmentTeacherController _controller = AssignmentTeacherController();

  @override
  void initState() {
    super.initState();
    print("Assignment ID: ${widget.assignmentId}");
    _controller.fetchAssignmentSubmissions(widget.assignmentId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(
            CupertinoIcons.back,
            color: Colors.black87,
            size: 28,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Assignment Details",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<AssignmentTeacherState>(
        valueListenable: _controller.stateNotifier,
        builder: (context, state, child) {
          if (state == AssignmentTeacherState.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state == AssignmentTeacherState.error) {
            return Center(child: Text("Error: ${_controller.errorMessage}"));
          } else if (state == AssignmentTeacherState.success) {
            // Use the first submission's assignment details for assignment info.
            final submissions = _controller.submissionDetails!.submissionsByAssignment;
            if (submissions.isEmpty) {
              return const Center(child: Text("No submissions available."));
            }
            final assignment = submissions.first.assignment;
            final totalSubmissions = submissions.length;
            // Format deadline date if available.
            final deadlineFormatted = assignment.deadline != null
                ? DateFormat.yMMMd().format(assignment.deadline!)
                : "No deadline";

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Assignment Details Section using fetched data.
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.indigo.shade50, Colors.indigo.shade100],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
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
                        // Title with icon.
                        Row(
                          children: [
                            const Icon(Icons.assignment,
                                color: Colors.indigo, size: 28),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                assignment.title ?? "No Title",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Description.
                        Text(
                          assignment.description ?? "No Description",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade800,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Deadline and total submissions.
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    color: Colors.indigo, size: 20),
                                const SizedBox(width: 4),
                                Text("Due: $deadlineFormatted",
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.indigo)),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Icons.people,
                                    color: Colors.indigo, size: 20),
                                const SizedBox(width: 4),
                                Text("Submissions: $totalSubmissions",
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.indigo)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Section Header for Student Submissions.
                  const Text(
                    "Submitted Students",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  // Student Card List.
                  ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: submissions.length,
                    separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final submission = submissions[index];
                      final student = submission.student;
                      return InkWell(
                        onTap: () {
                          // Navigate to EvaluationPage when tapping the student card.
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EvaluationPage(
                                submissionId: submission.submission.id ?? "",
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            // Glassmorphism-inspired semi-transparent background.
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.indigo.withOpacity(0.1),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Refined avatar with border and shadow.
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.indigo.shade200, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.indigo.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 30,
                                  backgroundImage: student.profilePicture != null && student.profilePicture!.isNotEmpty
                                      ? NetworkImage('${AppConfig.imageServer}${student.profilePicture}')
                                      : null,
                                  child: student.profilePicture == null || student.profilePicture!.isEmpty
                                      ? const Icon(Icons.person, size: 30)
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Student details.
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      student.name ?? "",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      student.roll ?? "",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Modern "Open" Button.
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PDFViewerPage(
                                        url: submission.submission.fileUrl ?? "",
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.picture_as_pdf,
                                    color: Colors.white, size: 20),
                                label: const Text("Open",
                                    style: TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigo,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
