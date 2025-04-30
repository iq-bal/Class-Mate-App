import 'package:classmate/controllers/profile_teacher/profile_teacher_controller.dart';
import 'package:classmate/views/profile_teacher/widgets/about_me_section.dart';
import 'package:classmate/views/profile_teacher/widgets/course_section.dart';
import 'package:classmate/views/profile_teacher/widgets/info_section.dart';
import 'package:classmate/views/profile_teacher/widgets/profile_header.dart';
import 'package:flutter/material.dart';

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
          if (state == ProfileTeacherState.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state == ProfileTeacherState.error) {
            return Center(child: Text(_controller.errorMessage ?? 'An error occurred'));
          } else if (state == ProfileTeacherState.success) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  ProfileHeader(
                    coverPhotoUrl: _controller.teacherProfile?.coverPicture != null
                        ? 'http://localhost:4001${_controller.teacherProfile!.coverPicture}'
                        : 'https://example.com/default_cover.jpg',
                    profilePhotoUrl: _controller.teacherProfile?.profilePicture != null
                        ? 'http://localhost:4001${_controller.teacherProfile!.profilePicture}'
                        : 'https://example.com/default_profile.jpg',
                    name: _controller.teacherProfile?.name ?? 'Unknown Name',
                    title: _controller.teacherProfile?.teacher?.designation ?? 'Unknown Title',
                  ),
                  const SizedBox(height: 80),
                  AboutMeSection(initialAboutMeText: _controller.teacherProfile?.teacher?.about ?? 'Unknown Title', onSave: (String value) {  },),
                  const SizedBox(height: 30),
                  InfoSection(
                    department: _controller.teacherProfile?.teacher?.department ?? 'Unknown Department',
                    designation: _controller.teacherProfile?.teacher?.designation ?? 'Unknown Designation',
                    email: _controller.teacherProfile?.email ?? 'Unknown Email',
                  ),
                  const SizedBox(height: 30),
                  CoursesSection(
                    courses: _controller.teacherProfile?.courses
                        ?.map((c) => UICourse(title: c.title, imagePath: c.image))
                        .toList() ?? [],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            );
          } else {
            return const SizedBox.shrink(); // Empty state
          }
        },
      ),
    );
  }
}
