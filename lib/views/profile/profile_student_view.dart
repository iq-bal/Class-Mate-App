import 'package:flutter/material.dart';
import 'package:classmate/controllers/profile_student/profile_student_controller.dart';
import 'package:classmate/models/profile_student/profile_student_model.dart';
import 'package:classmate/config/app_config.dart';
import 'widgets/profile_header.dart';
import 'widgets/about_section.dart';
import 'widgets/academic_info_card.dart';
import 'widgets/course_progress_section.dart';
import 'widgets/actions_section.dart';

class ProfileStudentView extends StatefulWidget {
  const ProfileStudentView({super.key});

  @override
  State<ProfileStudentView> createState() => _ProfileStudentViewState();
}

class _ProfileStudentViewState extends State<ProfileStudentView> {
  final ProfileStudentController _controller = ProfileStudentController();

  @override
  void initState() {
    super.initState();
    _controller.fetchStudentProfile();
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFEAEAF1);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: ValueListenableBuilder<ProfileStudentState>(
        valueListenable: _controller.stateNotifier,
        builder: (context, state, _) {
          if (state == ProfileStudentState.loading ||
              state == ProfileStudentState.idle) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state == ProfileStudentState.error) {
            return Center(
                child: Text(_controller.errorMessage ?? 'An error occurred'));
          }
          final profile = _controller.studentProfile!;
          return SingleChildScrollView(
            child: Column(
              children: [
                ProfileHeader(
                   coverImageUrl: profile.userId.coverPicture != null
                     ? '${AppConfig.imageServer}${profile.userId.coverPicture}'
                     : 'https://i.pravatar.cc/150?img=47',
                 profileImageUrl: profile.userId.profilePicture != null
                     ? '${AppConfig.imageServer}${profile.userId.profilePicture}'
                     : 'https://i.pravatar.cc/150?img=47',
                   onCoverImageEdit: _controller.updateCoverPhoto,
                   onProfileImageEdit: _controller.updateProfilePicture,
                 ),
                const SizedBox(height: 60),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Text(
                        profile.name,
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${profile.department} • ${profile.roll}',
                        style: const TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      const SizedBox(height: 24),
                      AboutSection(
                         aboutText: profile.about ?? 'No description available.',
                         profile: profile,
                         controller: _controller,
                       ),
                      const SizedBox(height: 24),
                      AcademicInfoCard(
                        department: profile.department,
                        semester: '${profile.semester}${_getOrdinalSuffix(int.tryParse(profile.semester) ?? 1)}',
                        cgpa: profile.cgpa,
                        status: "Active",
                      ),
                      const SizedBox(height: 24),
                      CourseProgressSection(
                        courses: _buildCourseList(profile.enrollments),
                      ),
                      const SizedBox(height: 24),
                      ActionsSection(
                        profile: profile,
                        controller: _controller,
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<CourseProgress> _buildCourseList(List<EnrollmentModel> enrollments) {
    final colors = [
      Colors.blueAccent,
      Colors.deepPurple,
      Colors.orangeAccent,
      Colors.green,
      Colors.redAccent,
      Colors.teal,
    ];
    
    List<CourseProgress> courses = [];
    int colorIndex = 0;
    
    for (var enrollment in enrollments) {
      if (enrollment.status == 'approved') {
        for (var course in enrollment.courses) {
          courses.add(CourseProgress(
            courseName: course.title,
            color: colors[colorIndex % colors.length],
          ));
          colorIndex++;
        }
      }
    }
    
    return courses;
  }

  String _getOrdinalSuffix(int number) {
    if (number >= 11 && number <= 13) {
      return 'th';
    }
    switch (number % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }
}
