import 'package:classmate/controllers/task/task_controller.dart';
import 'package:classmate/views/task/create_task_view.dart';
import 'package:flutter/material.dart';

class TaskView extends StatefulWidget {
  const TaskView({super.key});
  @override
  State<TaskView> createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> {
  final TaskController taskController = TaskController();

  @override
  void initState() {
    super.initState();
    taskController.getTasks();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Container(
            color: Colors.blue[900], // Solid background for the header
            child: const SafeArea(
              bottom: false, // Ensures only the top part is safe
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Spacer(),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "August 19",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "10 Tasks today",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                  ],
                ),
              ),
            ),
          ),

          // Horizontal Date Scroll
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.blue[900], // Solid background for the calendar
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1), // Shadow color
                  offset: const Offset(0, 4), // Offset to apply shadow at the bottom
                  blurRadius: 10, // Blur radius for the shadow
                  spreadRadius: 0, // Spread radius for sharper edges
                ),
              ],
            ),
            child: SafeArea(
              top: false, // Ensures only the bottom part is safe
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 7,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Column(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: index == 2 ? Colors.teal : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Center(
                            child: Text(
                              "16",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: index == 2 ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Mon",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // Task List Section with Background Image
          Expanded(
            child: Stack(
              children: [
                // Background Image
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/background.jpg', // Replace with your image path
                    fit: BoxFit.cover, // Ensures the image covers the task list area
                  ),
                ),
                // Task List Content
                ListView.builder(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Stack(
                        children: [
                          Positioned(
                            left: 16,
                            top: 20,
                            bottom: 20,
                            child: Container(
                              width: 2,
                              color: Colors.red,
                            ),
                          ),
                          Positioned(
                            left: 0,
                            top: 0,
                            child: Text(
                              "${7 + index}:00 AM",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            bottom: 0,
                            child: Text(
                              "${8 + index}:00 AM",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 64.0),
                            child: TaskCard(
                              index: index,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateTaskView()),
          );
        },
        backgroundColor: Colors.blue[900], // Button color
        child: const Icon(
          Icons.add, // Plus icon
          color: Colors.white, // White color for the icon
          size: 28, // Adjust icon size if needed
        ),
      ),
    );
  }
}

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
      elevation: 8, // Elevation for shadow effect
      margin: const EdgeInsets.symmetric(vertical: 8.0), // Add spacing between cards
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Softer corners
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Color strip on the left
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
            // Content section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row
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
                          onSelected: (value) {
                            // Handle menu item selection
                          },
                          itemBuilder: (BuildContext context) => [
                            const PopupMenuItem(
                              value: 'Edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem(
                              value: 'Delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Title
                    const Text(
                      "System Development Project",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Time Row
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          "7:00 AM - 9:00 AM",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const Spacer(),
                        // Avatar Row
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
                            const SizedBox(width: 4),
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.grey.shade300,
                              child: const Text(
                                "+4",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
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
