import 'package:flutter/material.dart';
import 'package:classmate/controllers/class_details_student/class_details_student_controller.dart';
import 'package:classmate/controllers/drive/drive_controller.dart';
import 'package:classmate/controllers/forum/forum_controller.dart';
import 'package:classmate/views/assignment/assignment_detail_view.dart';
import 'package:classmate/views/class_details_student/widgets/attendance_summary.dart';
import 'package:classmate/views/class_details_student/widgets/course_card_student.dart';
import 'package:classmate/views/class_details_student/widgets/custom_tab_bar.dart';
import 'package:classmate/views/assignment/widgets/custom_app_bar.dart';
import 'package:classmate/entity/drive_file_entity.dart';
import 'package:classmate/views/forum/forum_view.dart';
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
                            onMorePress: () {
                              print("More options clicked");
                            },
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
  
  void _showForumBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  // Bottom sheet handle
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Course Forum',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.grey[100],
                            foregroundColor: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Forum content
                  Expanded(
                    child: ForumView(courseId: widget.courseId),
                  ),
                ],
              ),
            );
          },
        );
      },
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
