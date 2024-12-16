import 'package:flutter/material.dart';

class AssignmentCard extends StatelessWidget {
  final String title;
  final String description;
  final String dueDate;
  final String iconText; // Text inside the icon
  final int totalItems;

  const AssignmentCard({
    super.key,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.iconText,
    required this.totalItems,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: const Border(
          top: BorderSide(color: Color(0xFFD9D9D9), width: 1.0), // Top border
          bottom: BorderSide(color: Color(0xFFD9D9D9), width: 1.0), // Bottom border
          left: BorderSide(color: Color(0xFFD9D9D9), width: 1.0), // Bottom border
          right: BorderSide(color: Color(0xFFD9D9D9), width: 1.0), // Bottom border
        ),
        // border: Border.all(color: const Color(0xFFD9D9D9), width: 1.0), // Border color and width
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Padding inside the card
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Title Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                    overflow: TextOverflow.ellipsis, // Add ellipsis for long text
                    maxLines: 1, // Limit to a single line
                  ),
                ),
                const Icon(Icons.arrow_forward, color: Colors.black),
              ],
            ),
            const SizedBox(height: 8), // Add spacing between the row and the border
            Container(
              width: double.infinity, // Full width
              height: 1.0, // Border thickness
              color: const Color(0xFFD9D9D9), // Border color
            ),

            const SizedBox(height: 16),
            // Middle Section
            Row(
              children: [
                // Icon Container
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      iconText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Texts
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis, // Add ellipsis
                        maxLines: 1, // Limit to a single line
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis, // Add ellipsis
                        maxLines: 2, // Limit to two lines
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Bottom Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 20, color: Colors.black),
                    const SizedBox(width: 8),
                    Text(
                      dueDate,
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.description, size: 20, color: Colors.black),
                    const SizedBox(width: 4),
                    Text(
                      totalItems.toString(),
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
