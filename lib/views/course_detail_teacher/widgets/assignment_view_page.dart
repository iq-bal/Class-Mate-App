import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'pdf_viewer_page.dart';
import 'evaluation_page.dart';

class Student {
  final String id;
  final String dpUrl;
  final String name;
  final String roll;
  final String submissionUrl;
  Student({
    required this.id,
    required this.dpUrl,
    required this.name,
    required this.roll,
    required this.submissionUrl,
  });
}

class AssignmentViewPage extends StatelessWidget {
  final String assignmentId;
  AssignmentViewPage({Key? key, required this.assignmentId}) : super(key: key);

  // Hardcoded assignment details (simulate fetching based on assignmentId)
  final String assignmentTitle = "Modern UI Assignment";
  final String assignmentDescription =
      "Develop an industry-grade assignment submission interface that emphasizes clarity, usability, and sophistication. Every detail—from clean typography to smooth interactions—has been designed for a professional experience.";
  final String dueDate = "2025-03-31";
  final int totalSubmissions = 3;

  // Hardcoded student submissions.
  final List<Student> submittedStudents = [
    Student(
      id: "S1",
      dpUrl: 'https://via.placeholder.com/150',
      name: 'John Doe',
      roll: '2021001',
      submissionUrl:
      'https://samples.jbpub.com/9781449649005/22183_ch01_pass3.pdf',
    ),
    Student(
      id: "S2",
      dpUrl: 'https://via.placeholder.com/150',
      name: 'Jane Smith',
      roll: '2021002',
      submissionUrl:
      'https://www3.nd.edu/~dgalvin1/10120/10120_S17/Topic04_6p4_Galvin_2017_short.pdf',
    ),
    Student(
      id: "S3",
      dpUrl: 'https://via.placeholder.com/150',
      name: 'Alice Johnson',
      roll: '2021003',
      submissionUrl:
      'https://samples.jbpub.com/9781449649005/22183_ch01_pass3.pdf',
    ),
  ];

  // Navigates to the in‑app PDF viewer.
  void openPDFViewer(String url, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PDFViewerPage(url: url)),
    );
  }

  // Navigates to the Evaluation Page, passing assignmentId and student roll.
  void openEvaluationPage(String studentId, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EvaluationPage(
          assignmentId: assignmentId,
          studentId: studentId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon:
          const Icon(CupertinoIcons.back, color: Colors.black87, size: 28),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom Assignment Details Section
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
                  // Assignment title with icon
                  Row(
                    children: [
                      const Icon(Icons.assignment,
                          color: Colors.indigo, size: 28),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          assignmentTitle,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Assignment description
                  Text(
                    assignmentDescription,
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[800],
                        height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  // Due date and submission count row
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              color: Colors.indigo, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            "Due: $dueDate",
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.indigo),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.people,
                              color: Colors.indigo, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            "Submissions: $totalSubmissions",
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.indigo),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Section header for student submissions.
            const Text(
              "Submitted Students",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            const SizedBox(height: 16),
            // Student Submission List
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: submittedStudents.length,
              separatorBuilder: (context, index) =>
              const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final student = submittedStudents[index];
                return InkWell(
                  onTap: () => openEvaluationPage(student.roll, context),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding:
                      const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      leading: CircleAvatar(
                        radius: 28,
                        backgroundImage:
                        NetworkImage(student.dpUrl),
                      ),
                      title: Text(
                        student.name,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                      subtitle: Text(
                        student.roll,
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600]),
                      ),
                      trailing: ElevatedButton.icon(
                        onPressed: () =>
                            openPDFViewer(student.submissionUrl, context),
                        icon: const Icon(Icons.picture_as_pdf,
                            color: Colors.white, size: 20),
                        label: const Text("Open",
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
