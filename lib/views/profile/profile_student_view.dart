import 'package:flutter/material.dart';
import 'widgets/profile_header.dart';
import 'widgets/about_section.dart';
import 'widgets/academic_info_card.dart';
import 'widgets/course_progress_section.dart';
import 'widgets/actions_section.dart';

class ProfileStudentView extends StatelessWidget {
  const ProfileStudentView({super.key});

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFEAEAF1);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProfileHeader(
              coverImageUrl: 'https://i.pravatar.cc/150?img=47',
              profileImageUrl: 'https://i.pravatar.cc/150?img=47',
              onCoverImageEdit: () => print('cover Edit clicked'),
              onProfileImageEdit: () => print('profile Edit clicked'),
            ),
            const SizedBox(height: 60),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const Text(
                    'Nashit Rahman',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'B.Sc in CSE • SHU20250123',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  AboutSection(
                    aboutText: 'Passionate learner, coder, and AI enthusiast.',
                    onEdit: () => print('Edit clicked'),
                  ),
                  const SizedBox(height: 24),
                  const AcademicInfoCard(
                    department: "Computer Science & Engineering",
                    semester: "6th",
                    cgpa: "3.86",
                    status: "Active",
                  ),
                  const SizedBox(height: 24),
                  CourseProgressSection(
                    courses: [
                      CourseProgress(
                        courseName: "Data Structures",
                        color: Colors.blueAccent,
                      ),
                      CourseProgress(
                        courseName: "AI & Machine Learning",
                        color: Colors.deepPurple,
                      ),
                      CourseProgress(
                        courseName: "Operating Systems",
                        color: Colors.orangeAccent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const ActionsSection(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
