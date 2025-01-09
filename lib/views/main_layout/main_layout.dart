// import 'package:classmate/views/chat/chat_view.dart';
import 'package:classmate/views/chat/chat_screen_view.dart';
import 'package:classmate/views/chat/chat_view.dart';
import 'package:classmate/views/explore/explore_course_view.dart';
import 'package:classmate/views/home/home_view.dart';
import 'package:classmate/views/main_layout/widgets/bottom_nav_item.dart';
import 'package:classmate/views/main_layout/widgets/modern_bottom_navbar.dart';
import 'package:flutter/material.dart';

class MainLayout extends StatefulWidget {
  final String role;

  const MainLayout({super.key, required this.role});

  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  List<Widget> _pages = [];
  List<BottomNavItem> _navItems = [];

  Future<void> _initializeLayout() async {
    // Simulate a delay if you need to fetch role-specific data
    await Future.delayed(const Duration(milliseconds: 200));

    // Define pages and navigation items based on the user's role
    if (widget.role.toLowerCase() == 'teacher') {
      _pages = [
        const Center(child: Text('Teacher Dashboard')),
        const Center(child: Text('Teacher Resources')),
        const Center(child: Text('Teacher Profile')),
      ];

      _navItems = [
        BottomNavItem(icon: Icons.dashboard, label: 'Dashboard'),
        BottomNavItem(icon: Icons.book, label: 'Resources'),
        BottomNavItem(icon: Icons.person, label: 'Profile'),
      ];
    } else {
      _pages = [
        const HomeView(),
        const ExploreCourseView(),
        const ChatView(),
      ];

      _navItems = [
        BottomNavItem(icon: Icons.schedule, label: 'Home'),
        BottomNavItem(icon: Icons.explore, label: 'Explore'),
        BottomNavItem(icon: Icons.chat_bubble_outline, label: 'Chat'),
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
    return FutureBuilder(
      future: _initializeLayout(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loader while initializing
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          // Handle any initialization errors
          return const Scaffold(
            body: Center(
              child: Text(
                'Something went wrong!',
                style: TextStyle(color: Colors.red, fontSize: 18),
              ),
            ),
          );
        }

        // Render the main layout once initialization is complete
        return Scaffold(
          body: _pages[_selectedIndex],
          bottomNavigationBar: ModernBottomNavBar(
            navItems: _navItems,
            selectedIndex: _selectedIndex,
            onItemSelected: _onItemTapped,
          ),
        );
      },
    );
  }
}
