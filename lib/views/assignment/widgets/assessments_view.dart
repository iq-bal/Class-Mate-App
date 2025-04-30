import 'package:classmate/core/helper_function.dart';
import 'package:flutter/material.dart';
import 'package:classmate/models/assignment/assignment_detail_model.dart';
import 'package:classmate/views/assignment/widgets/custom_app_bar.dart';
import 'package:classmate/views/assignment/widgets/info_card.dart';
import 'package:classmate/views/assignment/widgets/evaluation_card.dart';
import 'package:classmate/views/assignment/widgets/feedback_card.dart';

class AssessmentsView extends StatelessWidget {
  final AssignmentDetailModel assignmentDetail;


  const AssessmentsView({
    super.key,
    required this.assignmentDetail,
  });

  static const Color primaryTeal = Color(0xFF006966);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              CustomAppBar(
                title: 'Course Detail',
                onBackPress: () {
                  Navigator.pop(context);
                },
                onMorePress: () {
                  print("More options clicked");
                },
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InfoCard(
                      initials: HelperFunction.getFirstTwoLettersUppercase(assignmentDetail.assignment?.title ?? 'No Title'), // Example initials, adjust as needed
                      backgroundColor: primaryTeal,
                      title: assignmentDetail.assignment?.title ?? 'No Title',
                      description: assignmentDetail.assignment?.description ?? 'No Description',
                    ),
                    const SizedBox(height: 16),
                    EvaluationCard(
                      title: 'Evaluation',
                      legendItems: const [
                        {'color': Color(0xFFA1EDCD), 'label': 'greater is good'},
                        {'color': Color(0xFFE57373), 'label': 'lesser is good'},
                      ],
                      evaluationBars: [
                        {
                          'label': 'plagiarism',
                          'percentage': assignmentDetail.submission?.plagiarismScore ?? 0.0,
                          'isPositive': false
                        },
                        {
                          'label': 'grade',
                          'percentage': assignmentDetail.submission?.grade != null ? 100.0 : 0.0,
                          'isPositive': true
                        },
                        {
                          'label': 'ai generated',
                          'percentage': assignmentDetail.submission?.aiGenerated ?? 0.0,
                          'isPositive': false
                        },
                      ],
                    ),
                    const SizedBox(height: 16),
                    const FeedbackCard(
                      avatarUrl: 'https://via.placeholder.com/150', // Replace with dynamic avatar URL
                      date: '15 Nov, 2024', // Replace with dynamic date
                      feedback: 'Your works are overall good, but evaluation method could be better.', // Adjust based on assignment details
                      author: 'Dr. Al Mahmud', // Replace with dynamic author name
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
