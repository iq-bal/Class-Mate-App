import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AcademicInfoCard extends StatelessWidget {
  const AcademicInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _glassBox(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Academic Info",
              style: GoogleFonts.inter(
                  fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _infoRow("Department", "Computer Science & Engineering"),
          _infoRow("Semester", "6th"),
          _infoRow("CGPA", "3.86"),
          _infoRow("Status", "Active"),
        ],
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: GoogleFonts.inter(
                  color: Colors.grey[700], fontWeight: FontWeight.w500)),
          Text(value,
              style: GoogleFonts.inter(
                  color: Colors.black87, fontWeight: FontWeight.w600)),
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
