import 'package:flutter/material.dart';

class NextClassCard extends StatelessWidget {
  final String title;
  final String teacherName;
  final String timeRange;
  final IconData icon;
  final VoidCallback onTap;

  const NextClassCard({
    super.key,
    required this.title,
    required this.teacherName,
    required this.timeRange,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20), // Retains the card shape
      child: Container(
        width: 260,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
            const BoxShadow(
              color: Colors.white,
              blurRadius: 10,
              offset: Offset(-6, -6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon with Circular Glow
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Colors.blue.shade100, Colors.blue.shade100],
                      center: Alignment.center,
                      radius: 1,
                    ),
                  ),
                ),
                Icon(
                  icon,
                  size: 28,
                  color: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Class Name
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),

            // Teacher Name with Small Divider
            Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  teacherName,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Duration with Icon in Stylish Container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.blue.shade100, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    timeRange,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
