import 'package:flutter/material.dart';

class CourseCardStudent extends StatelessWidget {
  final String courseCode;
  final String className;
  final String day;
  final String time;
  final String title;
  final String roomNo;

  const CourseCardStudent({super.key, required this.courseCode, required this.className, required this.day, required this.time, required this.title, required this.roomNo});


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cursive',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              courseCode,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                fontFamily: 'Cursive',
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFD9D9D9)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Text(roomNo, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Container(
                        height: 16,
                        width: 1,
                        color: const Color(0xFFD9D9D9),
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      Text(className, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                // const SizedBox(height: 100),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFD9D9D9)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 8),
                      Text(day, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Container(
                        height: 16,
                        width: 1,
                        color: const Color(0xFFD9D9D9),
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      const Icon(Icons.access_time, size: 16),
                      const SizedBox(width: 4),
                      Text(time),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
