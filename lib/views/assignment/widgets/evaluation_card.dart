import 'package:classmate/views/assignment/widgets/evaluation_bar.dart';
import 'package:flutter/material.dart';

import '../../../utils/grid_painter.dart';

class EvaluationCard extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> legendItems;
  final List<Map<String, dynamic>> evaluationBars;

  const EvaluationCard({
    super.key,
    required this.title,
    required this.legendItems,
    required this.evaluationBars,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white, // Base background color
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Grid Background
          Positioned.fill(
            child: CustomPaint(
              painter: GridPainter(),
            ),
          ),
          // Evaluation Section Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row with Title and Legend
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Georgia',
                    ),
                  ),
                  Column(
                    children: legendItems.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: item['color'],
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item['label'],
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Bar Graph
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: evaluationBars.map((bar) {
                  return EvaluationBar(
                    label: bar['label'],
                    percentage: bar['percentage'],
                    isPositive: bar['isPositive'],
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
