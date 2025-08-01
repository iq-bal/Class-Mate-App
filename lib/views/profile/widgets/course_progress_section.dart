import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CourseProgressSection extends StatelessWidget {
  const CourseProgressSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _glassBox(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Courses",
              style: GoogleFonts.inter(
                  fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _progressTile("Data Structures", 0.8, Colors.blueAccent),
          _progressTile("AI & Machine Learning", 0.6, Colors.deepPurple),
          _progressTile("Operating Systems", 0.45, Colors.orangeAccent),
        ],
      ),
    );
  }

  Widget _progressTile(String name, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name,
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500, color: Colors.grey[800])),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _glassBox() {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.9),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 12,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }
}
