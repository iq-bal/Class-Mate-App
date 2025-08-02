import 'package:classmate/controllers/assignment/assignment_detail_controller.dart';
import 'package:classmate/views/assignment/widgets/assessments_view.dart';
import 'package:classmate/views/assignment/widgets/create_assignment_view.dart';
import 'package:flutter/material.dart';

import '../../models/assignment/assignment_detail_model.dart';
import '../../models/assignment/assignment_model.dart';

class AssignmentDetailPage extends StatefulWidget {
  final String assignmentId; // Assignment ID passed from parent

  const AssignmentDetailPage({
    super.key,
    required this.assignmentId,
  });

  @override
  State<AssignmentDetailPage> createState() => _AssignmentDetailPageState();
}

class _AssignmentDetailPageState extends State<AssignmentDetailPage> {
  final AssignmentDetailController _controller = AssignmentDetailController();
  bool isLoading = true;
  bool hasSubmission = false;

  @override
  void initState() {

    super.initState();
    debugPrint("Received Assignment ID: ${widget.assignmentId}");
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
      return AssessmentsView(
        assignmentDetail: _controller.assignmentDetail ?? const AssignmentDetailModel(),
      );
    }

    return CreateAssignmentView(
      assignmentModel: _controller.assignmentDetail?.assignment ?? const AssignmentModel(
        id: null,
        title: null,
        description: null,
      ),
    );
  }
}
