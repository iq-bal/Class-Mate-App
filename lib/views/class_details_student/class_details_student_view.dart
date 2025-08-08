import 'package:flutter/material.dart';
import 'package:classmate/controllers/class_details_student/class_details_student_controller.dart';
import 'package:classmate/controllers/drive/drive_controller.dart';
import 'package:classmate/controllers/forum/forum_controller.dart';
import 'package:classmate/controllers/quiz/student_quiz_controller.dart';
import 'package:classmate/models/quiz/student_quiz_model.dart';
import 'package:classmate/views/assignment/assignment_detail_view.dart';
import 'package:classmate/views/class_details_student/widgets/attendance_summary.dart';
import 'package:classmate/views/class_details_student/widgets/course_card_student.dart';
import 'package:classmate/views/class_details_student/widgets/custom_tab_bar.dart';
import 'package:classmate/views/assignment/widgets/custom_app_bar.dart';
import 'package:classmate/entity/drive_file_entity.dart';
import 'package:classmate/views/forum/forum_view.dart';
import 'package:classmate/views/course_overview_student/widgets/review_bottom_sheet.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/helper_function.dart';
import '../course_detail_teacher/widgets/assignment_card.dart';

class ClassDetailsStudent extends StatefulWidget {
  final String courseId;
  final String day;
  final String teacherId;

  const ClassDetailsStudent({
    super.key,
    required this.courseId,
    required this.day,
    required this.teacherId,
  });

  @override
  State<ClassDetailsStudent> createState() => _ClassDetailsStudentState();
}

class _ClassDetailsStudentState extends State<ClassDetailsStudent> {
  final ClassDetailsStudentController _controller = ClassDetailsStudentController();
  final DriveController _driveController = DriveController();
  final ForumController _forumController = ForumController();
  final StudentQuizController _quizController = StudentQuizController();
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchClassDetails();
  }

  void _fetchClassDetails() {
    print("------------------");
    print(widget.courseId);
    print(widget.day);
    print(widget.teacherId);
    print("------------------");
    _controller.fetchClassDetails(widget.courseId, widget.day, widget.teacherId);
  }

  List<PopupMenuEntry<String>> _buildMenuItems() {
    // Show review option for enrolled students
    return [
      const PopupMenuItem<String>(
        value: 'add_review',
        child: Row(
          children: [
            Icon(Icons.star_outline, size: 20, color: Colors.black54),
            SizedBox(width: 8),
            Text('Add Review'),
          ],
        ),
      ),
    ];
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'add_review':
        _showReviewBottomSheet();
        break;
    }
  }

  void _showReviewBottomSheet() {
    showReviewBottomSheet(
      context: context,
      courseId: widget.courseId,
      onReviewSubmitted: () {
        // Refresh the class details to show updated reviews
        _fetchClassDetails();
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ValueListenableBuilder<CourseDetailStudentState>(
          valueListenable: _controller.stateNotifier,
          builder: (context, state, child) {
            if (state == CourseDetailStudentState.loading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state == CourseDetailStudentState.error) {
              return Center(
                child: Text(
                  _controller.errorMessage ?? "An error occurred while fetching class details.",
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              );
            } else if (state == CourseDetailStudentState.success) {
              final details = _controller.classDetails;
              if (details == null) {
                return const Center(child: Text("No class details available."));
              }

              // UI for successful data fetch with sticky tab bar
              return NestedScrollView(
                headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomAppBar(
                            title: "Class Details",
                            onBackPress: () {
                              Navigator.pop(context);
                            },
                            menuItems: _buildMenuItems(),
                            onMenuSelected: _handleMenuSelection,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: CourseCardStudent(
                              courseCode: details.course.courseCode ?? "N/A",
                              className: details.schedule?.section ?? "N/A",
                              day: details.schedule?.day ?? "N/A",
                              time: "${HelperFunction.cleanTime(details.schedule?.startTime ?? "")} - ${HelperFunction.cleanTime(details.schedule?.endTime ?? "")}",
                              title: details.course.title ?? "N/A",
                              roomNo: details.schedule?.roomNo ?? "N/A",
                            ),
                          ),
                          const SizedBox(height: 16),
                          AttendanceSummary(
                            attendancePercentage: details.attendanceList.isEmpty
                                ? 0.0
                                : details.attendanceList
                                .where((e) => e.status?.toLowerCase() == "present")
                                .length /
                                details.attendanceList.length,
                            presenceIndicators: details.attendanceList
                                .map((e) => e.status?.toLowerCase() == "present" ? true : false)
                                .toList(),
                            feedbackText: HelperFunction.getAttendanceFeedback(
                              details.attendanceList.isEmpty
                                  ? 0.0
                                  : details.attendanceList
                                  .where((e) => e.status?.toLowerCase() == "present")
                                  .length /
                                  details.attendanceList.length,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    SliverPersistentHeader(
                      delegate: _StickyTabBarDelegate(
                        child: Container(
                          color: Colors.white,
                          child: Column(
                            children: [
                              CustomTabBar(
                                initialIndex: _selectedTabIndex,
                                onTabChanged: (index) {
                                  setState(() {
                                    _selectedTabIndex = index;
                                  });
                                  if (index == 1) { // Forum tab
                                    _forumController.fetchForumPosts(widget.courseId, refresh: true);
                                  } else if (index == 2) { // Materials tab
                                    _driveController.fetchDriveFiles(widget.courseId);
                                  } else if (index == 3) { // Quiz tab
                                    _quizController.loadQuizzes(widget.courseId);
                                  }
                                },
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                      pinned: true,
                    ),
                  ];
                },
                body: _buildTabContent(details),
              );
            } else {
              return const Center(child: Text("Unexpected state encountered."));
            }
          },
        ),
      ),
    );
  }

  Widget _buildTabContent(dynamic details) {
    Widget content;
    switch (_selectedTabIndex) {
      case 0: // Assignments
        content = _buildAssignmentsContent(details);
        break;
      case 1: // Forum
        content = _buildForumContent();
        break;
      case 2: // Materials
        content = _buildMaterialsContent();
        break;
      case 3: // Quiz
        content = _buildQuizContent();
        break;
      default:
        content = _buildAssignmentsContent(details);
        break;
    }
    
    return SingleChildScrollView(
      child: content,
    );
  }

  Widget _buildAssignmentsContent(dynamic details) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Assignments',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          ...details.assignments.map((assignment) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0), // Added padding for gap between cards
              child: AssignmentCard(
                title: assignment.title ?? "No Title",
                description: assignment.description ?? "No Description",
                dueDate: assignment.deadline != null
                    ? HelperFunction.formatISODate(assignment.deadline.toString())
                    : 'No Due Date',
                iconText: HelperFunction.getFirstTwoLettersUppercase(
                  assignment.title ?? "",
                ),
                totalItems: assignment.submissionCount ?? 0,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AssignmentDetailPage(assignmentId: assignment.id ?? ''),
                    ),
                  );
                },
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildForumContent() {
    return Container(
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [          
          // Forum content
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: ForumView(courseId: widget.courseId),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialsContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Materials',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder<DriveState>(
            valueListenable: _driveController.stateNotifier,
            builder: (context, state, child) {
              if (state == DriveState.loading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state == DriveState.error) {
                return Center(
                  child: Column(
                    children: [
                      Text(
                        _driveController.errorNotifier.value ?? 'Error loading files',
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => _driveController.fetchDriveFiles(widget.courseId),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              } else {
                return ValueListenableBuilder<List<DriveFileEntity>>(
                  valueListenable: _driveController.filesNotifier,
                  builder: (context, files, child) {
                    if (files.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            'No materials available for this course',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: files.map((file) {
                        return GestureDetector(
                          onTap: () => _openFile(file.fileUrl),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.08),
                                  spreadRadius: 2,
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  // File icon with modern container
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF6366F1).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        _driveController.getFileIcon(file.fileType),
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // File details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          file.fileName ?? 'Unknown File',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        if (file.description != null && file.description!.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 4.0),
                                            child: Text(
                                              file.description!,
                                              style: GoogleFonts.poppins(
                                                fontSize: 13,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ),
                                        Row(
                                          children: [
                                            Icon(Icons.storage, size: 14, color: Colors.grey[600]),
                                            const SizedBox(width: 4),
                                            Text(
                                              _driveController.formatFileSize(file.fileSize),
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Icon(Icons.person, size: 14, color: Colors.grey[600]),
                                            const SizedBox(width: 4),
                                            Text(
                                              file.teacher?.name ?? 'Unknown',
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Download icon
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.download_rounded,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _openFile(String? fileUrl) async {
    if (fileUrl != null && fileUrl.isNotEmpty) {
      try {
        final Uri url = Uri.parse(fileUrl);
        if (await canLaunchUrl(url)) {
          // Use LaunchMode.platformDefault to download the file instead of just opening it
          await launchUrl(url, mode: LaunchMode.platformDefault);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Downloading file...'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Could not download file'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error downloading file: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildQuizContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quizzes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder<StudentQuizState>(
            valueListenable: _quizController.stateNotifier,
            builder: (context, state, child) {
              if (state == StudentQuizState.loading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state == StudentQuizState.error) {
                return Center(
                  child: Column(
                    children: [
                      Text(
                        _quizController.errorMessage ?? 'Error loading quizzes',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => _quizController.retry(widget.courseId),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              } else if (state == StudentQuizState.taking) {
                return _buildQuizTakingInterface();
              } else if (state == StudentQuizState.submitting) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Submitting your answers...'),
                    ],
                  ),
                );
              } else if (state == StudentQuizState.submitted) {
                return _buildQuizSubmittedInterface();
              } else if (state == StudentQuizState.loaded) {
                final quizzes = _quizController.quizzes;
                
                if (quizzes.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'No active quizzes available for this course',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return Column(
                  children: quizzes.map((quiz) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.08),
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: quiz.mySubmission != null 
                                        ? Colors.green.shade100 
                                        : Colors.blue.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    quiz.mySubmission != null 
                                        ? Icons.check_circle 
                                        : Icons.quiz,
                                    color: quiz.mySubmission != null 
                                        ? Colors.green.shade600 
                                        : Colors.blue.shade600,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        quiz.testTitle,
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${quiz.questions.length} questions • ${quiz.duration} minutes • ${quiz.totalMarks} marks',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            
                            if (quiz.mySubmission != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.green.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.score, color: Colors.green.shade600, size: 16),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Score: ${quiz.mySubmission!.score}/${quiz.mySubmission!.totalMarks} (${quiz.mySubmission!.percentage.toStringAsFixed(1)}%)',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      'Attempt ${quiz.mySubmission!.attemptNumber}',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: Colors.green.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            
                            const SizedBox(height: 12),
                            
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: quiz.mySubmission != null 
                                    ? () {
                                        // Show submission details
                                        _showQuizResultDialog(quiz.mySubmission!);
                                      }
                                    : () {
                                        // Start quiz
                                        _quizController.startQuiz(quiz.id);
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: quiz.mySubmission != null 
                                      ? Colors.green.shade600 
                                      : Colors.blue.shade600,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  quiz.mySubmission != null ? 'View Results' : 'Start Quiz',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ],
      ),
    );
  }

  void _showQuizResultDialog(StudentQuizSubmission submission) {
    showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'Quiz Results',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            backgroundColor: Colors.blue.shade50,
            elevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
            ),
          ),
          body: Column(
            children: [
              // Summary Stats
              Container(
                padding: const EdgeInsets.all(20.0),
                color: Colors.blue.shade50,
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Score',
                        '${submission.score}/${submission.totalMarks}',
                        Icons.score,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Percentage',
                        '${submission.percentage.toStringAsFixed(1)}%',
                        Icons.percent,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Time',
                        '${submission.timeTaken}m',
                        Icons.timer,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Questions and Answers
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  child: submission.quiz?.questions != null
                      ? ListView.builder(
                          itemCount: submission.quiz!.questions!.length,
                          itemBuilder: (context, index) {
                            final question = submission.quiz!.questions![index];
                            final userAnswer = submission.answers?.firstWhere(
                              (a) => a.questionId == question.id,
                              orElse: () => StudentQuizAnswer(
                                questionId: question.id,
                                selectedAnswer: '',
                                isCorrect: false,
                              ),
                            );
                            
                            return Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: userAnswer?.isCorrect == true 
                                      ? Colors.green.shade300 
                                      : Colors.red.shade300,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Question header
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: userAnswer?.isCorrect == true 
                                              ? Colors.green.shade100 
                                              : Colors.red.shade100,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              userAnswer?.isCorrect == true 
                                                  ? Icons.check_circle 
                                                  : Icons.cancel,
                                              size: 16,
                                              color: userAnswer?.isCorrect == true 
                                                  ? Colors.green.shade600 
                                                  : Colors.red.shade600,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Question ${index + 1}',
                                              style: GoogleFonts.inter(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: userAnswer?.isCorrect == true 
                                                    ? Colors.green.shade700 
                                                    : Colors.red.shade700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        userAnswer?.isCorrect == true ? 'Correct' : 'Incorrect',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: userAnswer?.isCorrect == true 
                                              ? Colors.green.shade600 
                                              : Colors.red.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  const SizedBox(height: 12),
                                  
                                  // Question text
                                  Text(
                                    question.question,
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 16),
                                  
                                  // Options
                                  ..._buildResultOptions(question, userAnswer),
                                  
                                  if (userAnswer?.isCorrect == false) ...[
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.green.shade200),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.lightbulb_outline,
                                            size: 16,
                                            color: Colors.green.shade600,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Correct answer: ${question.answer}',
                                            style: GoogleFonts.inter(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.green.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Text(
                            'No detailed results available',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildResultOptions(StudentQuizQuestionWithAnswer question, StudentQuizAnswer? userAnswer) {
    final options = [
      ('A', question.options.a),
      ('B', question.options.b),
      ('C', question.options.c),
      ('D', question.options.d),
    ];

    return options.map((option) {
      final optionKey = option.$1;
      final optionText = option.$2;
      final isUserSelected = userAnswer?.selectedAnswer == optionKey;
      final isCorrectAnswer = question.answer == optionKey;
      
      Color backgroundColor = Colors.grey.shade50;
      Color borderColor = Colors.grey.shade300;
      Color textColor = Colors.grey.shade700;
      Widget? trailing;

      if (isCorrectAnswer) {
        backgroundColor = Colors.green.shade50;
        borderColor = Colors.green.shade300;
        textColor = Colors.green.shade700;
        trailing = Icon(Icons.check, color: Colors.green.shade600, size: 20);
      } else if (isUserSelected && !isCorrectAnswer) {
        backgroundColor = Colors.red.shade50;
        borderColor = Colors.red.shade300;
        textColor = Colors.red.shade700;
        trailing = Icon(Icons.close, color: Colors.red.shade600, size: 20);
      }

      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCorrectAnswer ? Colors.green.shade600 : 
                       isUserSelected ? Colors.red.shade600 : Colors.grey.shade400,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  optionKey,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                optionText,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      );
    }).toList();
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizTakingInterface() {
    final quiz = _quizController.currentQuiz!;
    
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.85, // Fixed total height
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Quiz Header
          Container(
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        quiz.testTitle,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ValueListenableBuilder<int>(
                        valueListenable: _quizController.timeNotifier,
                        builder: (context, timeRemaining, child) {
                          return Text(
                            _quizController.getFormattedTimeRemaining(),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Progress: ${_quizController.currentAnswers.length}/${quiz.questions.length} questions answered',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Questions - Fixed height scrollable area
          Container(
            height: MediaQuery.of(context).size.height * 0.55, // Fixed height for questions
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ListView.builder(
              itemCount: quiz.questions.length,
              itemBuilder: (context, index) {
                final question = quiz.questions[index];
                final selectedAnswer = _quizController.currentAnswers[question.id];
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selectedAnswer != null 
                          ? Colors.green.shade300 
                          : Colors.grey.shade300,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.05),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Question ${index + 1}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        question.question,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Options
                      _buildQuizOption('A', question.options.a, selectedAnswer, question.id),
                      _buildQuizOption('B', question.options.b, selectedAnswer, question.id),
                      _buildQuizOption('C', question.options.c, selectedAnswer, question.id),
                      _buildQuizOption('D', question.options.d, selectedAnswer, question.id),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // Submit Button - Fixed at bottom
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Exit Quiz'),
                          content: const Text('Are you sure you want to exit? Your progress will be lost.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _quizController.exitQuiz();
                              },
                              child: const Text('Exit'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text('Exit Quiz'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _quizController.areAllQuestionsAnswered
                        ? () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Submit Quiz'),
                                content: const Text('Are you sure you want to submit your answers?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _quizController.submitQuiz();
                                    },
                                    child: const Text('Submit'),
                                  ),
                                ],
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Submit Quiz',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizOption(String optionKey, String optionText, String? selectedAnswer, int questionId) {
    final isSelected = selectedAnswer == optionKey;
    
    return GestureDetector(
      onTap: () {
        _quizController.updateAnswer(questionId, optionKey);
        setState(() {}); // Trigger rebuild to show selection
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue.shade300 : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue.shade600 : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  optionKey,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                optionText,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: isSelected ? Colors.blue.shade800 : Colors.grey.shade700,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizSubmittedInterface() {
    final submission = _quizController.lastSubmission!;
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              size: 64,
              color: Colors.green.shade600,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Quiz Submitted Successfully!',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildResultRow('Score', '${submission.score}/${submission.totalMarks}'),
                _buildResultRow('Percentage', '${submission.percentage.toStringAsFixed(1)}%'),
                _buildResultRow('Time Taken', '${submission.timeTaken} minutes'),
                _buildResultRow('Attempt', '${submission.attemptNumber}'),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _quizController.resetToQuizList();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Back to Quizzes',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _quizController.dispose();
    super.dispose();
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyTabBarDelegate({required this.child});

  @override
  double get minExtent => 80.0;

  @override
  double get maxExtent => 80.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
