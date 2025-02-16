import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:classmate/views/assignment/widgets/custom_app_bar.dart';
import 'package:classmate/views/assignment/widgets/info_card.dart';
import 'package:classmate/views/assignment/widgets/evaluation_card.dart';
import 'package:classmate/views/assignment/widgets/feedback_card.dart';

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

  @override
  void initState() {
    super.initState();
    // Pre-fill with example values
    _gradeController = TextEditingController(text: "85");
    _commentsController = TextEditingController(
        text:
        "Your work is overall good, but the evaluation method could be improved.");
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
      // Process the evaluation and display confirmation.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Submitted: Grade: ${_gradeController.text}, Comments: ${_commentsController.text}"),
          backgroundColor: Colors.indigo,
        ),
      );
      Navigator.pop(context); // close the bottom sheet
    }
  }

  // Function to show the evaluation modal bottom sheet
  void _showEvaluationModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // allows the modal to adjust for keyboard
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        // Wrap content in Padding to account for keyboard
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo.shade50, Colors.indigo.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Colors.indigo, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
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
                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Colors.indigo, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
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
                        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
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

  @override
  Widget buildMainContent(BuildContext context) {
    // Use MediaQuery to dynamically adjust the bottom padding when the keyboard appears.
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    return SingleChildScrollView(
      padding: EdgeInsets.only(
          left: 16, right: 16, top: 12, bottom: bottomPadding + 16),
      child: Column(
        children: [
          CustomAppBar(
            title: 'Course Detail',
            onBackPress: () => Navigator.pop(context),
            onMorePress: _showEvaluationModal,
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Card with hardcoded assignment details.
                InfoCard(
                  initials: 'CH',
                  backgroundColor: EvaluationPage.primaryTeal,
                  title: "Hardcoded Assignment Title",
                  description:
                  "This is a hardcoded assignment description. It provides details about the assignment and its requirements.",
                ),
                const SizedBox(height: 16),
                // Evaluation Card with hardcoded evaluation stats.
                EvaluationCard(
                  title: 'Evaluation',
                  legendItems: const [
                    {'color': Color(0xFFA1EDCD), 'label': 'greater is good'},
                    {'color': Color(0xFFE57373), 'label': 'lesser is good'},
                  ],
                  evaluationBars: [
                    {'label': 'Plagiarism', 'percentage': 20.0, 'isPositive': false},
                    {'label': 'Grade', 'percentage': 85.0, 'isPositive': true},
                    {'label': 'AI Generated', 'percentage': 40.0, 'isPositive': false},
                  ],
                ),
                const SizedBox(height: 16),
                // Feedback Card with sample feedback.
                const FeedbackCard(
                  avatarUrl: 'https://via.placeholder.com/150',
                  date: '15 Nov, 2024',
                  feedback:
                  'Your work is overall good, but evaluation method could be better.',
                  author: 'Dr. Al Mahmud',
                ),
                const SizedBox(height: 24),
              ],
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
