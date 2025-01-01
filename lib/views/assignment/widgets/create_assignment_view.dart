import 'package:classmate/controllers/assignment/assignment_detail_controller.dart';
import 'package:classmate/core/helper_function.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:classmate/models/assignment/assignment_model.dart';
import 'package:classmate/views/assignment/widgets/attachment_section.dart';
import 'package:classmate/views/assignment/widgets/custom_app_bar.dart';
import 'package:classmate/views/assignment/widgets/info_card.dart';
import 'package:classmate/views/assignment/widgets/terms_and_conditions.dart';

class CreateAssignmentView extends StatefulWidget {
  final AssignmentModel assignmentModel;

  const CreateAssignmentView({
    super.key,
    required this.assignmentModel,
  });

  @override
  State<CreateAssignmentView> createState() => _CreateAssignmentViewState();
}

class _CreateAssignmentViewState extends State<CreateAssignmentView> {

  final Color borderColor = Colors.grey.shade300;
  static const Color primaryTeal = Color(0xFF006966);
  final Color greyTextColor = Colors.grey.shade800;
  static const Color lightGreenBackground = Color(0xFFDFFFE0);
  int selectedIndex = 0;
  String? uploadedFileName;
  final AssignmentDetailController _controller = AssignmentDetailController();
  PlatformFile? selectedFile;

  // Define terms and conditions
  final List<Map<String, dynamic>> terms = [
    {
      'title': 'Plagiarism Detection',
      'description':
      'All submissions will be automatically checked for plagiarism to ensure originality and academic integrity. Submitting copied content may result in disciplinary action as per the institution\'s policies.',
      'icon': Icons.shield,
    },
    {
      'title': 'AI-Generated Text Detection',
      'description':
      'Submissions will be analyzed for AI-generated content to maintain fairness and ensure the authenticity of your work. Any detected violations may lead to review and possible rejection of the submission.',
      'icon': Icons.settings,
    },
    {
      'title': 'Permission to Access Storage',
      'description':
      'We require permission to access your device storage to upload files for assignment submissions. This access is only used for academic purposes and in compliance with privacy guidelines.',
      'icon': Icons.file_copy,
    },
    {
      'title': 'Academic Honesty Agreement',
      'description':
      'By submitting your assignment, you agree to adhere to the principles of academic honesty, ensuring that the work is your own and complies with institutional guidelines.',
      'icon': Icons.bookmark,
    },
    {
      'title': 'Submission Policy Acknowledgment',
      'description':
      'Please confirm that you understand the submission policies, including checks for plagiarism and AI-generated content, before uploading your assignment.',
      'icon': Icons.check,
    },
  ];

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null) {
      final file = result.files.first;
      setState(() {
        uploadedFileName = file.name; // Update the file name
        selectedFile = file; // Save the selected file
      });
    } else {
      print("No file selected");
    }
  }

  Future<void> _submitAssignment() async {
    String assignmentId = "6770faec4ba49e91eade309d";
    if (selectedFile != null) {
      await _controller.submitAssignment(
        assignmentId, // Replace with actual assignment ID
        selectedFile!.path!,
      );

      if (_controller.stateNotifier.value == AssignmentDetailState.success) {
        await HelperFunction.showNotification(
            "Submission Successful",
            "Your assignment has been submitted successfully!"
        );
        Navigator.pop(context); // Navigate back to the parent page
      } else if (_controller.stateNotifier.value == AssignmentDetailState.error) {
        await HelperFunction.showNotification(
            "Submission Failed",
            "An error occurred while submitting your assignment. Please try again."
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              CustomAppBar(
                title: 'Create Assignment',
                onBackPress: () {
                  Navigator.pop(context);
                },
                onMorePress: () {
                  print("More options clicked");
                },
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.error, size: 16, color: Colors.red),
                    SizedBox(width: 4),
                    Text(
                      '2 days left',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InfoCard(
                      initials: widget.assignmentModel.title?.substring(0, 2).toUpperCase() ?? "N/A",
                      backgroundColor: primaryTeal,
                      title: widget.assignmentModel.title ?? "No Title",
                      description: widget.assignmentModel.description ?? "No Description",
                    ),
                    const SizedBox(height: 16),
                    Column(
                      children: List.generate(terms.length, (index) {
                        final isSelected = selectedIndex == index;
                        final item = terms[index];
                        return TermsAndConditionsCard(
                          title: item['title'],
                          description: item['description'],
                          icon: item['icon'],
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              selectedIndex = index;
                            });
                          },
                          borderColor: borderColor,
                          selectedBackgroundColor: lightGreenBackground,
                        );
                      }),
                    ),

                    AttachmentSection(
                        uploadedFileName: uploadedFileName,
                        onRemoveFile: () {
                          setState(() {
                            uploadedFileName = null;
                            selectedFile = null;
                          });
                          },
                        onPickFile: _pickFile,
                        onSubmit: _submitAssignment,
                        isFileUploaded: uploadedFileName != null,
                        borderColor: borderColor,
                        buttonColor: primaryTeal
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
