import 'dart:math';
import 'package:flutter/material.dart';
import 'package:classmate/controllers/explore/explore_course_controller.dart';
import 'widgets/search_section.dart';
import 'widgets/search_result_section.dart';
import 'widgets/recommended_section.dart';
import 'widgets/popular_section.dart';

class ExploreCourseView extends StatefulWidget {
  const ExploreCourseView({super.key});

  @override
  State<ExploreCourseView> createState() => _ExploreCourseViewState();
}

class _ExploreCourseViewState extends State<ExploreCourseView> {

  @override
  void initState() {
    super.initState();
    exploreCourseController.loadAllCourses();
    exploreCourseController.loadPopularCourses();// Load all courses initially
  }


  final ExploreCourseController exploreCourseController = ExploreCourseController();
  final TextEditingController searchController = TextEditingController();

  final List<IconData> courseIcons = [
    Icons.design_services,
    Icons.code,
    Icons.science,
    Icons.computer,
    Icons.graphic_eq,
    Icons.analytics,
    Icons.engineering,
    Icons.language,
    Icons.music_note,
    Icons.sports_basketball
  ];

  final List<Color> courseColors = [
    Colors.green[100]!,
    Colors.blue[100]!,
    Colors.orange[100]!,
    Colors.purple[100]!,
    Colors.red[100]!,
    Colors.yellow[100]!,
    Colors.teal[100]!,
    Colors.pink[100]!,
  ];

  Color getRandomCourseColor() => courseColors[Random().nextInt(courseColors.length)];
  IconData getRandomCourseIcon() => courseIcons[Random().nextInt(courseIcons.length)];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text('Explore Courses'),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
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
                  const Text("What's new to learn?", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  SearchSection(
                    searchController: searchController,
                    onSearch: (value) {
                      if (value.isNotEmpty) {
                        exploreCourseController.searchCourses(value);
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  SearchResultSection(
                    state: state,
                    controller: exploreCourseController,
                    getRandomIcon: getRandomCourseIcon,
                    getRandomColor: getRandomCourseColor,
                  ),
                  const SizedBox(height: 24),
                  RecommendedSection(
                    getRandomIcon: getRandomCourseIcon,
                    getRandomColor: getRandomCourseColor,
                    courses: exploreCourseController.allCourses ?? [],
                  ),
                  const SizedBox(height: 24),
                  exploreCourseController.popularCourses == null ||
                      exploreCourseController.popularCourses!.isEmpty
                      ? const Text('No popular courses found.')
                      : PopularSection(course: exploreCourseController.popularCourses![0]),

                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
