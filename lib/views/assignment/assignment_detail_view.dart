import 'package:classmate/controllers/assignment/assignment_detail_controller.dart';
import 'package:classmate/views/assignment/widgets/assessments_view.dart';
import 'package:classmate/views/assignment/widgets/create_assignment_view.dart';
import 'package:flutter/material.dart';

import '../../models/assignment/assignment_detail_model.dart';
import '../../models/assignment/assignment_model.dart';

class AssignmentDetailPage extends StatefulWidget {

  final String assignmentId="675cba0a097be65e5ced61b9"; // Assignment ID to fetch details for

  const AssignmentDetailPage({super.key});

  @override
  State<AssignmentDetailPage> createState() => _AssignmentDetailPageState();
}

class _AssignmentDetailPageState extends State<AssignmentDetailPage> {
  final AssignmentDetailController _controller = AssignmentDetailController();
  bool isLoading = true; // Tracks loading state for submission check
  bool hasSubmission = false; // Tracks whether submission exists

  @override
  void initState() {
     super.initState();
     _fetchAssignmentDetails();
  }

  Future<void> _fetchAssignmentDetails() async {
    await _controller.getAssignmentDetails(widget.assignmentId);
    setState(() {
      hasSubmission = _controller.assignmentDetail?.submission != null;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (hasSubmission) {
      return AssessmentsView(assignmentDetail: _controller.assignmentDetail??const AssignmentDetailModel());
    }

    return const CreateAssignmentView(
      assignmentModel: AssignmentModel(
        id: "123",
        title: "Data Structures",
        description: "Complete tasks on Linked Lists.",
      ),
    );
  }
}
