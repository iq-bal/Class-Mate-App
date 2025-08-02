import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AcademicInfoCard extends StatelessWidget {
  final String department;
  final String semester;
  final String cgpa;
  final String status;

  const AcademicInfoCard({
    super.key,
    required this.department,
    required this.semester,
    required this.cgpa,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _glassBox(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Academic Info",
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _infoRow("Department", department),
          _infoRow("Semester", semester),
          _infoRow("CGPA", cgpa),
          _infoRow("Status", status),
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
          Text(
            title,
            style: GoogleFonts.inter(
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
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
