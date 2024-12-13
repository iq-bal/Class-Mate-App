import 'package:flutter/material.dart';

class CourseCard extends StatelessWidget {
  final String courseCode;
  final String className;
  final String day;
  final String time;
  final String title;
  final String roomNo;
  final VoidCallback onAttend;
  final VoidCallback onReschedule;

  const CourseCard({
    super.key,
    required this.courseCode,
    required this.className,
    required this.day,
    required this.time,
    required this.title,
    required this.roomNo,
    required this.onAttend,
    required this.onReschedule,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        const SizedBox(height: 16),
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
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 3,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: onAttend,
                child: const Text('Attend', style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.black),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: onReschedule,
                child: const Text('Reschedule', style: TextStyle(color: Colors.black)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
