import 'package:classmate/controllers/create_course/schedule_controller.dart';
import 'package:flutter/material.dart';
import 'package:classmate/controllers/create_course/create_course_controller.dart';
import 'package:classmate/controllers/create_course/syllabus_controller.dart';
import 'package:classmate/views/create_course/widgets/course_info_page.dart';
import 'package:classmate/views/create_course/widgets/schedule_page.dart';
import 'package:classmate/views/create_course/widgets/syllabus_page.dart';
import 'package:classmate/models/create_course/create_course_model.dart';

class CreateCourseScreen extends StatefulWidget {
  const CreateCourseScreen({super.key});

  @override
  State<CreateCourseScreen> createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<CreateCourseScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final CreateCourseController _controller = CreateCourseController();
  final SyllabusController _syllabusController = SyllabusController();
  final ScheduleController _scheduleController = ScheduleController();  // Initialize ScheduleController

  CreateCourseModel? createdCourse;
  Map<String, List<String>> finalSyllabus = {};

  // Course fields
  String courseTitle = '';
  String courseCode = '';
  double courseCredit = 0.0;
  String courseExcerpt = '';
  String courseDescription = '';
  String courseImage = '';

  // Next page function
  void _nextPage() async {
    if (_currentPage == 0) {
      // Page 1: Create Course
      await _controller.createCourse(
        title: courseTitle,
        courseCode: courseCode,
        credit: courseCredit,
        description: courseDescription,
        excerpt: courseExcerpt,
        imagePath: courseImage,
      );

      if (_controller.stateNotifier.value == CreateCourseState.success) {
        createdCourse = _controller.createdCourse;
        setState(() {
          _currentPage++;
        });
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create course. Please try again.')),
        );
      }
    } else if (_currentPage == 1) {
      // Page 2: Update Syllabus
      if (createdCourse != null) {
        // Call the syllabus update function
        await _syllabusController.updateSyllabus(
          courseId: createdCourse!.id,
          syllabusData: finalSyllabus,
        );

        if (_syllabusController.stateNotifier.value == SyllabusState.success) {
          setState(() {
            _currentPage++;
          });
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update syllabus. Please try again.')),
          );
        }
      }
    } else if (_currentPage == 2) {
      // Page 3: Schedule Page (Save schedules)
      if (_currentPage < 2) {
        setState(() {
          _currentPage++;
        });
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _submitCourse() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Course - Step ${_currentPage + 1}/3'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                CourseInfoPage(
                  onTitleChanged: (value) => setState(() => courseTitle = value),
                  onCourseCodeChanged: (value) => setState(() => courseCode = value),
                  onCreditChanged: (value) => setState(() => courseCredit = value),
                  onExcerptChanged: (value) => setState(() => courseExcerpt = value),
                  onDescriptionChanged: (value) => setState(() => courseDescription = value),
                  onImageChanged: (value) => setState(() => courseImage = value),
                ),
                SyllabusPage(
                  courseId: createdCourse?.id ?? '',
                  onSyllabusChanged: (data) {
                    setState(() => finalSyllabus = data);  // Store updated syllabus data
                  },
                ),
                SchedulePage(
                  courseId: createdCourse?.id ?? '',  // Pass the courseId to SchedulePage
                  scheduleController: _scheduleController,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                if (_currentPage > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousPage,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.blueAccent),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Back', style: TextStyle(fontSize: 16, color: Colors.blueAccent)),
                    ),
                  ),
                if (_currentPage > 0) const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _currentPage == 2 ? _submitCourse : _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      _currentPage == 2 ? 'Submit' : 'Next',
                      style: const TextStyle(fontSize: 16),
                    ),
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
