import 'package:flutter/material.dart';


class SubtleGridBackground extends StatelessWidget {
  final Widget child;

  const SubtleGridBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: GridPainter(),
      child: child,
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.grey.withOpacity(0.1) // Subtle grid color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const double gridSize = 24; // Grid cell size

    // Draw vertical lines
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
