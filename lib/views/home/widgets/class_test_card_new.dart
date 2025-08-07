import 'package:flutter/material.dart';

class ClassTestCard extends StatelessWidget {
  final String subject;
  final String title;
  final String description;
  final int durationMin;
  final int points;
  final String dueText;

  const ClassTestCard({
    super.key,
    required this.subject,
    required this.title,
    required this.description,
    required this.durationMin,
    required this.points,
    required this.dueText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: Colors.blue.shade50, // Subtle blue background
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // White inner card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8), // rectangular with slight rounding
                      ),
                      child: Icon(Icons.menu_book_outlined, size: 24, color: Colors.blue),
                    ),
                    SizedBox(width: 8),
                    Text(
                      subject,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    _infoBox(Icons.access_time, '$durationMin Min'),
                    SizedBox(width: 12),
                    _infoBox(Icons.star_border, '$points pts'),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          Text(
            dueText,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBox(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18,color: Colors.blue),
          const SizedBox(width: 6),
          Text(label,style: const TextStyle(
            color: Colors.blue
          ),),
        ],
      ),
    );
  }
}
