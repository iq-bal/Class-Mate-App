import 'dart:math';
import 'package:classmate/views/assignment_teacher/pdf_viewer_page.dart';
import 'package:flutter/material.dart';
import 'package:classmate/controllers/assignment_teacher/assignment_teacher_controller.dart';

import '../../utils/custom_app_bar.dart';
import '../assignment/widgets/evaluation_card.dart';
import '../assignment/widgets/feedback_card.dart';
import '../assignment/widgets/info_card.dart';

class EvaluationPage extends StatefulWidget {
  final String assignmentId;
  final String studentId;
  static const Color primaryTeal = Color(0xFF006966);

  const EvaluationPage({
    super.key,
    required this.assignmentId,
    required this.studentId,
  });

  @override
  State<EvaluationPage> createState() => _EvaluationPageState();
}

class _EvaluationPageState extends State<EvaluationPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _gradeController;
  late TextEditingController _commentsController;
  late AssignmentTeacherController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AssignmentTeacherController();
    _controller.fetchSingleSubmission(widget.assignmentId, widget.studentId);

    _gradeController = TextEditingController();
    _commentsController = TextEditingController();

    // Update controllers when evaluation details are available
    _controller.stateNotifier.addListener(() {
      if (_controller.stateNotifier.value == AssignmentTeacherState.success &&
          _controller.evaluationDetail != null) {
        setState(() {
          _gradeController.text = _controller.evaluationDetail!.submission.grade?.toString() ?? '';
          _commentsController.text = _controller.evaluationDetail!.submission.teacherComments ?? '';
        });
      }
    });
  }

  @override
  void dispose() {
    _gradeController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  void _submitEvaluation() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Create submission input map
      Map<String, dynamic> submissionInput = {
        'grade': double.parse(_gradeController.text),
        'teacher_comments': _commentsController.text,
        'assignment_id': widget.assignmentId,
        'student_id': widget.studentId
      };

      // Call updateSubmission with the current submission ID and new data
      final submissionId = _controller.evaluationDetail?.submission.id;
      if (submissionId != null) {
        _controller.updateSubmission(
            submissionId,
            submissionInput
        ).then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Evaluation submitted successfully"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context); // Closes the evaluation modal
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error submitting evaluation: ${error.toString()}"),
              backgroundColor: Colors.red,
            ),
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error: Submission ID not found"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Show the evaluation input modal.
  void _showEvaluationModal() {
    // Set initial values from evaluationDetail
    if (_controller.evaluationDetail != null) {
      _gradeController.text = _controller.evaluationDetail!.submission.grade?.toString() ?? '';
      _commentsController.text = _controller.evaluationDetail!.submission.teacherComments ?? '';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Adjust for keyboard
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade200,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    "Enter Grade",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo.shade800,
                      fontFamily: 'Georgia',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _gradeController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: "Enter grade",
                      hintStyle: TextStyle(
                        fontFamily: 'Georgia',
                        color: Colors.grey.shade500,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 16),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Colors.transparent),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Colors.indigo, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide:
                        const BorderSide(color: Colors.redAccent, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter a grade";
                      }
                      final n = num.tryParse(value);
                      if (n == null) {
                        return "Enter a valid number";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Enter Comments",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo.shade800,
                      fontFamily: 'Georgia',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _commentsController,
                    maxLines: 4,
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: "Enter comments",
                      hintStyle: TextStyle(
                        fontFamily: 'Georgia',
                        color: Colors.grey.shade500,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 16),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Colors.transparent),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Colors.indigo, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide:
                        const BorderSide(color: Colors.redAccent, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: _submitEvaluation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 48, vertical: 18),
                      ),
                      child: const Text(
                        "Submit Evaluation",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Build the main content using the updated CustomAppBar with a popup menu.
  Widget buildMainContent(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    return SingleChildScrollView(
      padding: EdgeInsets.only(
          left: 16, right: 16, top: 12, bottom: bottomPadding + 16),
      child: Column(
        children: [
          CustomAppBar(
            title: 'Course Detail',
            onBackPress: () => Navigator.pop(context),
            // Use the onMenuSelected callback for custom menu items.
            onMenuSelected: (value) {
              if (value == 'open' && _controller.evaluationDetail?.submission.fileUrl != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PDFViewerPage(
                      url: _controller.evaluationDetail!.submission.fileUrl!,
                    ),
                  ),
                );
              } else if (value == 'evaluate') {
                _showEvaluationModal();
              }
            },
            menuItems: const [
              PopupMenuItem(value: 'open', child: Text("Open PDF Work")),
              PopupMenuItem(value: 'evaluate', child: Text("Evaluate")),
            ],
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 16),
            child: ValueListenableBuilder<AssignmentTeacherState>(
              valueListenable: _controller.stateNotifier,
              builder: (context, state, child) {
                if (state == AssignmentTeacherState.loading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state == AssignmentTeacherState.error) {
                  return Center(child: Text(_controller.errorMessage ?? 'An error occurred'));
                } else if (state == AssignmentTeacherState.success && _controller.evaluationDetail != null) {
                  final evaluation = _controller.evaluationDetail!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InfoCard(
                        initials: (evaluation.teacher.name ?? 'UN').substring(0, min(2, (evaluation.teacher.name ?? 'UN').length)).toUpperCase(),
                        backgroundColor: EvaluationPage.primaryTeal,
                        title: evaluation.assignment.title ?? 'Untitled Assignment',
                        description: evaluation.assignment.description ?? 'No description provided',
                      ),
                      const SizedBox(height: 16),
                      EvaluationCard(
                        title: 'Evaluation',
                        legendItems: const [
                          {'color': Color(0xFFA1EDCD), 'label': 'greater is good'},
                          {'color': Color(0xFFE57373), 'label': 'lesser is good'},
                        ],
                        evaluationBars: [
                          {'label': 'Plagiarism', 'percentage': evaluation.submission.plagiarismScore ?? 0.0, 'isPositive': false},
                          {'label': 'Grade', 'percentage': evaluation.submission.grade ?? 0.0, 'isPositive': true},
                          {'label': 'AI Generated', 'percentage': evaluation.submission.aiGenerated == true ? 100.0 : 0.0, 'isPositive': false},
                        ],
                      ),
                      const SizedBox(height: 16),
                      FeedbackCard(
                        avatarUrl: evaluation.teacher.profilePicture ?? 'https://via.placeholder.com/150',
                        date: evaluation.submission.evaluatedAt != null
                            ? evaluation.submission.evaluatedAt!.toString().substring(0, 10)
                            : 'Not evaluated yet',
                        feedback: evaluation.submission.teacherComments ?? 'No feedback provided yet',
                        author: evaluation.teacher.name ?? 'Unknown Teacher',
                      ),
                      const SizedBox(height: 24),
                    ],
                  );
                }
                return const Center(child: Text('No data available'));
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(child: buildMainContent(context)),
    );
  }
}
