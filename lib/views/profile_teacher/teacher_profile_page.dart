import 'package:flutter/material.dart';
import 'package:classmate/controllers/profile_teacher/profile_teacher_controller.dart';
import 'package:classmate/views/profile_teacher/widgets/about_me_section.dart';
import 'package:classmate/views/profile_teacher/widgets/course_section.dart';
import 'package:classmate/views/profile_teacher/widgets/info_section.dart';
import 'package:classmate/views/profile_teacher/widgets/profile_header.dart';

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
                      ? 'http://localhost:4001${profile.coverPicture}'
                      : 'https://example.com/default_cover.jpg',
                  profilePhotoUrl: profile.profilePicture != null
                      ? 'http://localhost:4001${profile.profilePicture}'
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
                      ?.map((c) => UICourse(title: c.title, imagePath: c.image))
                      .toList() ??
                      [],
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
