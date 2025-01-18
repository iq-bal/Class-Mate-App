import 'package:flutter/material.dart';

class TaskCard extends StatelessWidget {
  final int index;

  const TaskCard({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.blue.shade400,
      Colors.green.shade400,
      Colors.orange.shade400,
      Colors.purple.shade400,
      Colors.cyan.shade400
    ];

    return Card(
      elevation: 8,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 8,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors[index % colors.length].withOpacity(0.9),
                    colors[index % colors.length].withOpacity(0.7),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          "Project",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.more_vert,
                            size: 20,
                            color: Colors.grey,
                          ),
                          onSelected: (value) {},
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'Edit', child: Text('Edit')),
                            const PopupMenuItem(value: 'Delete', child: Text('Delete')),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "System Development Project",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        const Text(
                          "7:00 AM - 9:00 AM",
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 14,
                              backgroundImage: AssetImage('assets/images/avatar.png'),
                            ),
                            const SizedBox(width: 4),
                            const CircleAvatar(
                              radius: 14,
                              backgroundImage: AssetImage('assets/images/avatar.png'),
                            ),
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.grey.shade300,
                              child: const Text(
                                "+4",
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
