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
            return AssignmentCard(
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
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildForumContent() {
    return Container(
      height: 500, // Set a fixed height for the forum content
      child: ForumView(courseId: widget.courseId),
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
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF6366F1).withOpacity(0.1),
                              child: Text(
                                _driveController.getFileIcon(file.fileType),
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                            title: Text(
                              file.fileName ?? 'Unknown File',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Size: ${_driveController.formatFileSize(file.fileSize)}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                if (file.description != null && file.description!.isNotEmpty)
                                  Text(
                                    file.description!,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                Text(
                                  'Uploaded by: ${file.teacher?.name ?? 'Unknown'}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.open_in_new),
                              onPressed: () => _openFile(file.fileUrl),
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
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Could not open file'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error opening file: $e'),
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
