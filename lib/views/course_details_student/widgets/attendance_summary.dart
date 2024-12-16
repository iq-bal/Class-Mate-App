import 'package:flutter/material.dart';
import 'dart:math' as math;

class AttendanceSummary extends StatelessWidget {
  final double attendancePercentage; // e.g., 0.85 for 85%
  final List<bool?> presenceIndicators; // True = Present, False = Absent, Null = not occurred yet
  final String feedbackText;

  const AttendanceSummary({
    super.key,
    required this.attendancePercentage,
    required this.presenceIndicators,
    required this.feedbackText,
  });

  @override
  Widget build(BuildContext context) {
    final int percentage = (attendancePercentage * 100).toInt();

    return Container(
      color: Colors.white,
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "Your Presence" header with a custom style
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            child: Text(
              'Your Presence',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.teal[800],
                fontFamily: 'Georgia', // or any serif-like font
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Attendance percentage label on the left, pie chart on the right
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side: "Attendance percentage" text
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Attendance percentage',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontFamily: 'Arial',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$percentage%',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[800],
                      ),
                    ),
                  ],
                ),
              ),

              // Right side: Actual pie chart using CustomPaint
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.topRight,
                  child: SizedBox(
                    height: 150,
                    width: 150,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(80, 80),
                          painter: PieChartPainter(
                            attendanceRatio: attendancePercentage,
                            attendanceColor: Colors.teal,
                            absenceColor: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // "Presence this semester" text
          const Text(
            'Presence this semester',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontFamily: 'Arial',
            ),
          ),

          const SizedBox(height: 8),

          // Horizontal row of squares
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(
              presenceIndicators.length,
                  (index) {
                final status = presenceIndicators[index];
                Color fillColor;
                Color textColor;
                BoxBorder? border;

                if (status == true) {
                  fillColor = Colors.teal;
                  textColor = Colors.white;
                  border = Border.all(color: Colors.teal, width: 1);
                } else if (status == false) {
                  fillColor = Colors.red;
                  textColor = Colors.white;
                  border = Border.all(color: Colors.red, width: 1);
                } else {
                  fillColor = Colors.white;
                  textColor = Colors.black;
                  border = Border.all(color: Colors.black, width: 1);
                }

                return Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: fillColor,
                    borderRadius: BorderRadius.circular(6),
                    border: border,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Feedback section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Colors.grey.shade100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.thumb_up, color: Colors.grey.shade600, size: 20),
                const SizedBox(width: 8),
                RichText(
                  text: TextSpan(
                    text: 'Great! ',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    children: [
                      TextSpan(
                        text: feedbackText,
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A custom painter for drawing a simple two-segment pie chart:
/// - Green portion: attendanceRatio * 360 degrees
/// - Red portion: remainder of the circle
class PieChartPainter extends CustomPainter {
  final double attendanceRatio;
  final Color attendanceColor;
  final Color absenceColor;

  PieChartPainter({
    required this.attendanceRatio,
    required this.attendanceColor,
    required this.absenceColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2;

    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = radius;
    final startAngle = -math.pi / 2; // Start at top
    final attendanceAngle = 2 * math.pi * attendanceRatio;

    // Draw absence portion (full circle background)
    paint.color = absenceColor;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      2 * math.pi,
      false,
      paint,
    );

    // Draw attendance portion on top
    paint.color = attendanceColor;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      attendanceAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(PieChartPainter oldDelegate) {
    return oldDelegate.attendanceRatio != attendanceRatio ||
        oldDelegate.attendanceColor != attendanceColor ||
        oldDelegate.absenceColor != absenceColor;
  }
}
