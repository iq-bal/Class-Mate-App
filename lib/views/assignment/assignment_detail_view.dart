import 'package:classmate/controllers/assignment/assignment_detail_controller.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class AssignmentDetailPage extends StatefulWidget {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top AppBar-like section
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            color: primaryTeal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              'CH',
                              style: TextStyle(
                                color: primaryTeal,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cache Memory performance Evaluation',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  fontFamily: 'Georgia',
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Computer Architecture is a fundamental area of computer science that focuses on the design, structure, and organization of computer systems...',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Terms and conditions cards
                    Column(
                      children: List.generate(terms.length, (index) {
                        final isSelected = selectedIndex == index;
                        final item = terms[index];

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIndex = index; // Update which card is selected
                            });
                          },
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected ? lightGreenBackground : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected ? Colors.green.shade200 : borderColor,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? const Color(0xFFA1EDCD)
                                            : borderColor,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(8),
                                      child: Icon(
                                        item['icon'] as IconData,
                                        color: Colors.black54,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        item['title'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Georgia',
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item['description'],
                                  style: TextStyle(fontSize: 14, color: greyTextColor),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),

                    const Text(
                      'Attachment',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.attach_file, color: Colors.black87),
                              const SizedBox(width: 8),
                              Text(
                                uploadedFileName ?? 'your_roll.pdf',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          if (uploadedFileName != null) // Display the close button only if a file is uploaded
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  uploadedFileName = null; // Reset file name
                                });
                              },
                              child: const Icon(Icons.close, color: Colors.black54),
                            ),
                        ],
                      ),
                    ),


                    const SizedBox(height: 16),

                    // SizedBox(
                    //   width: double.infinity,
                    //   height: 48,
                    //   child: ElevatedButton.icon(
                    //     style: ElevatedButton.styleFrom(
                    //       backgroundColor: primaryTeal,
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(8),
                    //       ),
                    //     ),
                    //     icon: uploadedFileName != null
                    //         ? Transform.rotate(
                    //       angle: -3.141592653589793 / 4, // pi/4 radians
                    //       child: const Icon(
                    //         Icons.send,
                    //         color: Colors.white,
                    //       ),
                    //     )
                    //         : const Icon(
                    //       Icons.upload_file,
                    //       color: Colors.white,
                    //     ),
                    //     label: Text(
                    //       uploadedFileName != null ? 'Turn In' : 'Upload Task',
                    //       style: const TextStyle(fontSize: 16, color: Colors.white),
                    //     ),
                    //     onPressed: _pickFile,
                    //   ),
                    // ),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryTeal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: uploadedFileName != null
                            ? Transform.rotate(
                          angle: -3.141592653589793 / 4, // pi/4 radians
                          child: const Icon(
                            Icons.send,
                            color: Colors.white,
                          ),
                        )
                            : const Icon(
                          Icons.upload_file,
                          color: Colors.white,
                        ),
                        label: Text(
                          uploadedFileName != null ? 'Turn In' : 'Upload Task',
                          style: const TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        onPressed: uploadedFileName != null
                            ? () async {
                          if (selectedFile != null) {
                            await _controller.submitAssignment(
                              "675cba0a097be65e5ced61b9", // Replace with actual assignment ID
                              selectedFile!.path!, // Path of the selected file
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
                            : _pickFile,
                      ),
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
