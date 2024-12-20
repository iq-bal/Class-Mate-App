import 'package:flutter/material.dart';

class CustomTabBar extends StatefulWidget {
  const CustomTabBar({super.key});

  @override
  _CustomTabBarState createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar> {
  int _selectedIndex = 0; // Track the currently selected tab

  final List<String> tabs = ['Assignment', 'Forum', 'Materials'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Custom Tab Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: List.generate(tabs.length, (index) {
              final isSelected = _selectedIndex == index;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = index; // Update selected tab index
                    });
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Tab Text
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0), // Space before border
                        child: Text(
                          tabs[index],
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 16,
                            color: isSelected ? Colors.black : Colors.grey,
                          ),
                        ),
                      ),

                      // Bottom Border
                      Container(
                        height: 2, // Border height
                        color: isSelected
                            ? Colors.teal // Teal color for selected tab
                            : const Color(0xFFD9D9D9), // Grey for other tabs
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
