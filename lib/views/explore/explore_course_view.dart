import 'dart:math';
import 'package:classmate/controllers/explore/explore_course_controller.dart';
import 'package:flutter/material.dart';
import 'package:classmate/views/explore/widgets/course_card.dart';

class ExploreCourseView extends StatefulWidget {
  const ExploreCourseView({super.key});

  @override
  State<ExploreCourseView> createState() => _ExploreCourseViewState();
}

class _ExploreCourseViewState extends State<ExploreCourseView> {
  int highlightedIndex = 0; // Track which card is highlighted
  final ExploreCourseController exploreCourseController = ExploreCourseController();
  final TextEditingController searchController = TextEditingController();

  List<IconData> courseIcons = [
    Icons.design_services, // UI Design
    Icons.code,            // Python
    Icons.science,         // Data Science
    Icons.computer,        // Computer Science
    Icons.graphic_eq,      // Graphic Design
    Icons.analytics,       // Data Analytics
    Icons.engineering,     // Engineering
    Icons.language,        // Language Studies
    Icons.music_note,      // Music
    Icons.sports_basketball // Sports
  ];

  List<Color> courseColors = [
    Colors.green[100]!,  // Represents growth, creativity, and innovation (UI Design)
    Colors.blue[100]!,   // Represents trust, logic, and programming (Python)
    Colors.orange[100]!, // Represents energy, curiosity, and exploration (Data Science)
    Colors.purple[100]!, // Represents imagination and inspiration (Creative Courses)
    Colors.red[100]!,    // Represents passion and determination (Challenging Topics)
    Colors.yellow[100]!, // Represents optimism and learning (Beginner Topics)
    Colors.teal[100]!,   // Represents balance and communication (Collaboration)
    Colors.pink[100]!,   // Represents care and engagement (Social Sciences)
  ];

  Color getRandomCourseColor() {
    final random = Random();
    return courseColors[random.nextInt(courseColors.length)];
  }

  IconData getRandomCourseIcon() {
    final random = Random();
    return courseIcons[random.nextInt(courseIcons.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Courses'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: ValueListenableBuilder<ExploreCourseState>(
        valueListenable: exploreCourseController.stateNotifier,
        builder: (context, state, _) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "What's new to learn?",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search the course',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: const Icon(Icons.tune),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        exploreCourseController.searchCourses(value);
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  if (state == ExploreCourseState.loading)
                    const Center(child: CircularProgressIndicator())
                  else if (state == ExploreCourseState.error)
                    Center(
                      child: Text(
                        exploreCourseController.errorMessage ?? 'An error occurred',
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                  else if (state == ExploreCourseState.success && exploreCourseController.courses != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Search Results",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          if (exploreCourseController.courses!.isEmpty)
                            const Center(
                              child: Text("No courses found.", style: TextStyle(fontSize: 16)),
                            )
                          else
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: exploreCourseController.courses!.map((course) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 16),
                                    child: CourseCard(
                                      courseId: course.id?? "N/A",
                                      icon: getRandomCourseIcon(),
                                      title: course.title ?? "Unknown Course",
                                      courseCode: course.courseCode ?? "N/A",
                                      description: course.description ?? "No description available.",
                                      backgroundColor: getRandomCourseColor(),
                                      isHighlighted: false,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                        ],
                      ),
                  const SizedBox(height: 24),
                  const Text(
                    "Recommended for you",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        CourseCard(
                          courseId: "675c910186e75d98dc7c5cae",
                          icon: getRandomCourseIcon(),
                          title: "UI Design",
                          courseCode: "CSE 3211",
                          description: "Create impactful & delightful digital designs.",
                          backgroundColor: getRandomCourseColor(),
                          isHighlighted: false,
                        ),
                        const SizedBox(width: 16),
                        CourseCard(
                          courseId: "675c910186e75d98dc7c5cae",
                          icon: getRandomCourseIcon(),
                          title: "Python",
                          courseCode: "CSE 3221",
                          description: "Code programs with improved skills.",
                          backgroundColor: getRandomCourseColor(),
                          isHighlighted: false,
                        ),
                        const SizedBox(width: 16),
                        CourseCard(
                          courseId: "675c910186e75d98dc7c5cae",
                          icon: getRandomCourseIcon(),
                          title: "Data Science",
                          courseCode: "CSE 3231",
                          description: "Analyze and interpret complex data.",
                          backgroundColor: getRandomCourseColor(),
                          isHighlighted: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Popular",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.yellow[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "UX Design",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                            "Design experiences that drive user behavior and delight people."
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                "24 lessons",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                "42 hours",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    "In progress",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.timer, size: 40),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Visual Design",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text("10 lessons left"),
                          ],
                        ),
                        Spacer(),
                        Icon(Icons.arrow_forward_ios),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
