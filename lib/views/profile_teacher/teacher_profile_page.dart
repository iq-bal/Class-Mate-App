import 'package:flutter/material.dart';
import 'package:classmate/controllers/profile_teacher/profile_teacher_controller.dart';
import 'package:classmate/views/profile_teacher/widgets/about_me_section.dart';
import 'package:classmate/views/profile_teacher/widgets/course_section.dart';
import 'package:classmate/views/profile_teacher/widgets/info_section.dart';
import 'package:classmate/views/profile_teacher/widgets/profile_header.dart';
import 'package:classmate/config/app_config.dart';

class TeacherProfilePage extends StatefulWidget {
  const TeacherProfilePage({super.key});

  @override
  State<TeacherProfilePage> createState() => _TeacherProfilePageState();
}

class _TeacherProfilePageState extends State<TeacherProfilePage> {
  final ProfileTeacherController _controller = ProfileTeacherController();

  @override
  void initState() {
    super.initState();
    _controller.fetchTeacherProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<ProfileTeacherState>(
        valueListenable: _controller.stateNotifier,
        builder: (context, state, _) {
          if (state == ProfileTeacherState.loading ||
              state == ProfileTeacherState.idle) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state == ProfileTeacherState.error) {
            return Center(
                child: Text(_controller.errorMessage ?? 'An error occurred'));
          }
          final profile = _controller.teacherProfile!;
          return SingleChildScrollView(
            child: Column(
              children: [
                ProfileHeader(
                  coverPhotoUrl: profile.coverPicture != null
                      ? '${AppConfig.imageServer}${profile.coverPicture}'
                      : 'https://example.com/default_cover.jpg',
                  profilePhotoUrl: profile.profilePicture != null
                      ? '${AppConfig.imageServer}${profile.profilePicture}'
                      : 'https://example.com/default_profile.jpg',
                  name: profile.name,
                  title: profile.teacher?.designation ?? '',
                  // Pass **this** controller’s methods down
                  onProfilePictureChange: _controller.updateProfilePicture,
                  onCoverPhotoChange:     _controller.updateCoverPhoto,
                ),

                const SizedBox(height: 80),

                AboutMeSection(
                  initialAboutMeText: profile.teacher?.about ?? '',
                  onSave: _controller.updateTeacherAbout,
                ),

                const SizedBox(height: 30),

                InfoSection(
                  department:  profile.teacher?.department  ?? '',
                  designation: profile.teacher?.designation ?? '',
                  email:       profile.email,
                ),

                const SizedBox(height: 30),

                CoursesSection(
                  courses: profile.courses
                      ?.map((c) => UICourse(
                            id: c.id,
                            title: c.title,
                            imagePath: c.image,
                          ))
                      .toList() ??
                      [],
                  onDeleteCourse: (courseId) async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Course'),
                        content: const Text('Are you sure you want to delete this course?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true) {
                      try {
                        await _controller.deleteCourse(courseId);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Course deleted successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString().replaceAll('Exception: ', '')),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  },
                ),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }
}
