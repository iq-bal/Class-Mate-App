import 'package:flutter/material.dart';
import 'info_row.dart';

class InfoSection extends StatelessWidget {
  final String designation;
  final String email;
  final String department;

  const InfoSection({
    super.key,
    required this.designation,
    required this.email,
    required this.department,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          InfoRow(
            icon: Icons.grade,
            info: designation,  // dynamic designation
          ),
          const SizedBox(height: 15),
          InfoRow(
            icon: Icons.email,
            info: email,  // dynamic email
          ),
          const SizedBox(height: 15),
          InfoRow(
            icon: Icons.business,
            info: department,  // dynamic department
          ),
        ],
      ),
    );
  }
}
