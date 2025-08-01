import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

    return const Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProfileHeader(),
            SizedBox(height: 60),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Text(
                    'Nashit Rahman',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'B.Sc in CSE • SHU20250123',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  SizedBox(height: 24),
                  AboutSection(),
                  SizedBox(height: 24),
                  AcademicInfoCard(),
                  SizedBox(height: 24),
                  CourseProgressSection(),
                  SizedBox(height: 24),
                  ActionsSection(),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
