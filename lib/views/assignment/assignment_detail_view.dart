import 'package:classmate/controllers/assignment/assignment_detail_controller.dart';
import 'package:classmate/services/assignment/assignment_detail_service.dart';
import 'package:classmate/utils/grid_painter.dart';
import 'package:classmate/views/assignment/widgets/attachment_section.dart';
import 'package:classmate/views/assignment/widgets/custom_app_bar.dart';
import 'package:classmate/views/assignment/widgets/evaluation_bar.dart';
import 'package:classmate/views/assignment/widgets/evaluation_card.dart';
import 'package:classmate/views/assignment/widgets/feedback_card.dart';
import 'package:classmate/views/assignment/widgets/info_card.dart';
import 'package:classmate/views/assignment/widgets/terms_and_conditions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class AssignmentDetailPage extends StatefulWidget {

  final String assignmentId="675cba0a097be65e5ced61b9"; // Assignment ID to fetch details for

  const AssignmentDetailPage({super.key});

  @override
  State<AssignmentDetailPage> createState() => _AssignmentDetailPageState();
}

class _AssignmentDetailPageState extends State<AssignmentDetailPage> {
  final Color borderColor = Colors.grey.shade300;
  static const Color primaryTeal = Color(0xFF006966);
  static const Color lightGreenBackground = Color(0xFFDFFFE0);
  static const Color redWarningColor = Colors.red;
  final Color greyTextColor = Colors.grey.shade800;

  int selectedIndex = 0; // Track which card is selected
  String? uploadedFileName; // Holds the uploaded file name
  final AssignmentDetailController _controller = AssignmentDetailController();
  PlatformFile? selectedFile; // Holds the selected file details
  bool isLoading = true; // Tracks loading state for submission check
  bool hasSubmission = false; // Tracks whether submission exists

  final AssignmentDetailService _service = AssignmentDetailService();

  @override
  void initState() {
     super.initState();
     _checkSubmission();
  }


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


  Future<void> _checkSubmission() async {
    await _controller.checkAssignmentSubmission("675cba0a097be65e5ced61b9"); // Replace with actual assignment ID
    if (_controller.stateNotifier.value == AssignmentDetailState.success) {
      setState(() {
        hasSubmission = true;
        isLoading = false;
      });
    } else {
      setState(() {
        hasSubmission = false;
        isLoading = false;
      });
    }
  }


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
    if (selectedFile != null) {
      await _controller.submitAssignment(
        "675cba0a097be65e5ced61b9", // Replace with actual assignment ID
        selectedFile!.path!,
      );

      if (_controller.stateNotifier.value == AssignmentDetailState.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Assignment submitted successfully!")),
        );
      } else if (_controller.stateNotifier.value == AssignmentDetailState.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_controller.errorMessage ?? "An error occurred")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (hasSubmission) {
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
                      const InfoCard(
                        initials: 'CH',
                        backgroundColor: primaryTeal,
                        title: 'Cache Memory performance Evaluation',
                        description:
                        'Computer Architecture is a fundamental area of computer science that focuses on the design, structure, and organization of computer systems...',
                      ),
                      const SizedBox(height: 16),
                      const EvaluationCard(
                        title: 'Evaluation',
                        legendItems: [
                          {'color': Color(0xFFA1EDCD), 'label': 'greater is good'},
                          {'color': Color(0xFFE57373), 'label': 'lesser is good'},
                        ],
                        evaluationBars: [
                          {'label': 'plagiarism', 'percentage': 75.0, 'isPositive': false}, // Add `.0` to convert to double
                          {'label': 'grade', 'percentage': 85.0, 'isPositive': true}, // Add `.0` to convert to double
                          {'label': 'ai generated', 'percentage': 40.0, 'isPositive': false}, // Add `.0` to convert to double
                          {'label': 'performance', 'percentage': 60.0, 'isPositive': true}, // Add `.0` to convert to double
                        ],
                      ),
                      const SizedBox(height: 16),
                      const FeedbackCard(
                        avatarUrl: 'https://via.placeholder.com/150', // Replace with the actual avatar URL
                        date: '15 Nov, 2024',
                        feedback: 'Your works are overall good, but evaluation method could be better. I think your method suggests an alternate approach towards the problem.',
                        author: 'Dr. Al Mahmud',
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _controller.getAssignmentDetails("675cba0a097be65e5ced61b9");
                        },
                        child: const Text("Press Me"),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }


    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.arrow_back_ios, size: 18, color: Colors.black),
                        SizedBox(width: 4),
                        Text(
                          'Course Detail',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    Icon(Icons.more_vert, color: Colors.black54),
                  ],
                ),
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
                    Icon(Icons.error, size: 16, color: redWarningColor),
                    SizedBox(width: 4),
                    Text(
                      '2 days left',
                      style: TextStyle(
                        color: redWarningColor,
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
                    const InfoCard(initials: 'CH', backgroundColor: primaryTeal, title: 'Cache Memory performance Evaluation', description: 'Computer Architecture is a fundamental area of computer science that focuses on the design, structure, and organization of computer systems...'),
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
                              selectedIndex = index; // Update which card is selected
                            });
                          },
                          borderColor: borderColor,
                          selectedBackgroundColor: lightGreenBackground,
                        );
                      }),
                    ),
                    AttachmentSection(
                        uploadedFileName: uploadedFileName,
                        onRemoveFile: () {setState(() {
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
