import 'package:classmate/controllers/chat/socket_controller.dart';
import 'package:classmate/views/course_detail_teacher/course_detail_teacher_view.dart';
import 'package:classmate/views/home_teacher/home_teacher_view.dart';
import 'package:classmate/views/task/task_view.dart';
import 'package:flutter/material.dart';
import 'package:classmate/views/home/home_view.dart';
import 'package:classmate/views/explore/explore_course_view.dart';
import 'package:classmate/views/chat/chat_view.dart';
import 'package:classmate/views/profile/profile_view.dart';
import 'package:classmate/views/main_layout/widgets/bottom_nav_item.dart';
import 'package:classmate/views/main_layout/widgets/modern_bottom_navbar.dart';
import 'package:classmate/views/teacher_dashboard/teacher_dashboard_view.dart';
import 'package:classmate/views/profile/teacher_profile_view.dart';
import 'package:classmate/views/profile/student_profile_view.dart';

class MainLayout extends StatefulWidget {
  final String role;

  const MainLayout({super.key, required this.role});

  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  late List<Widget> _pages;
  late List<BottomNavItem> _navItems;


  // final SocketController _socketController = SocketController();


  @override
  void initState() {
    super.initState();
    _initializeLayout();
    // _initializeSocket();
  }

  @override
  void dispose() {
    // _socketController.disconnectSocket();
    super.dispose();
  }
  //
  // Future<void> _initializeSocket() async {
  //   await _socketController.initializeSocket();
  // }

  void _initializeLayout() {
    if (widget.role.toLowerCase() == 'teacher') {
      _pages = [
        const TeacherDashboardView(),
        const ExploreCourseView(),
        const ChatView(),
        const TeacherProfileView(),
        const StudentProfileView(),
      ];

      _navItems = [
        BottomNavItem(
          icon: Icons.dashboard_outlined,
          activeIcon: Icons.dashboard,
          label: 'Dashboard',
        ),
        BottomNavItem(
          icon: Icons.explore_outlined,
          activeIcon: Icons.explore,
          label: 'Explore',
        ),
        BottomNavItem(
          icon: Icons.chat_bubble_outline,
          activeIcon: Icons.chat_bubble,
          label: 'Chat',
        ),
        BottomNavItem(
          icon: Icons.person_outline,
          activeIcon: Icons.person,
          label: 'Profile',
        ),
        BottomNavItem(
          icon: Icons.school_outlined,
          activeIcon: Icons.school,
          label: 'Student',
        ),
      ];
    } else {
      _pages = [
        const HomeView(),
        const TaskView(),
        const ExploreCourseView(),
        const ChatView(),
        const ProfileScreen(),
      ];

      _navItems = [
        BottomNavItem(icon: Icons.schedule, label: 'Home'),
        BottomNavItem(icon: Icons.task, label: 'Task'),
        BottomNavItem(icon: Icons.explore, label: 'Explore'),
        BottomNavItem(icon: Icons.chat_bubble_outline, label: 'Chat'),
        BottomNavItem(icon: Icons.person, label: "Profile"),
      ];
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: ModernBottomNavBar(
        navItems: _navItems,
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemTapped,
      ),
    );
  }
}
