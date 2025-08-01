import 'package:flutter/material.dart';

class ExpandableLessonTile extends StatefulWidget {
  final int lessonNumber;
  final String lessonTitle;
  final String duration;
  final bool isLocked;
  final List<String> topics;

  const ExpandableLessonTile({
    required this.lessonNumber,
    required this.lessonTitle,
    required this.duration,
    required this.isLocked,
    required this.topics,
    super.key,
  });

  @override
  State<ExpandableLessonTile> createState() => _ExpandableLessonTileState();
}

class _ExpandableLessonTileState extends State<ExpandableLessonTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!widget.isLocked) {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.isLocked ? Colors.grey[200] : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      '${widget.lessonNumber}.',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.lessonTitle,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.access_time,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      widget.duration,
                      style:
                      const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      widget.isLocked
                          ? Icons.lock
                          : (_isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down),
                      color: widget.isLocked ? Colors.grey : Colors.green,
                    ),
                  ],
                ),
              ],
            ),
            if (_isExpanded)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.topics.map((topic) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle,
                              size: 16, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            topic,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ExpandableLessonList extends StatelessWidget {
  final List<Map<String, dynamic>> lessons;

  const ExpandableLessonList({
    required this.lessons,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: lessons.map((lesson) {
          return Column(
            children: [
              ExpandableLessonTile(
                lessonNumber: lesson['lessonNumber'],
                lessonTitle: lesson['lessonTitle'],
                duration: lesson['duration'],
                isLocked: lesson['isLocked'],
                topics: lesson['topics'],
              ),
              const SizedBox(height: 8),
            ],
          );
        }).toList(),
      ),
    );
  }
}
