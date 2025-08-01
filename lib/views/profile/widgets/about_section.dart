import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _glassBox(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("About Me",
              style: GoogleFonts.inter(
                  fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(
            "Passionate learner, coder, and AI enthusiast. Currently pursuing Computer Science & Engineering at Shadow University. I enjoy building digital solutions and contributing to open-source.",
            style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[800],
                height: 1.5,
                letterSpacing: 0.3),
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
