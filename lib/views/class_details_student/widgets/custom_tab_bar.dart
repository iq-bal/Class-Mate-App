import 'package:flutter/material.dart';

class CustomTabBar extends StatefulWidget {
  final Function(int)? onTabChanged;
  final int initialIndex;
  
  const CustomTabBar({
    super.key,
    this.onTabChanged,
    this.initialIndex = 0,
  });

  @override
  _CustomTabBarState createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar> {
  late int _selectedIndex; // Track the currently selected tab

  final List<String> tabs = ['Assignment', 'Forum', 'Materials', 'Quiz'];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Custom Tab Bar - Horizontally Scrollable
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: List.generate(tabs.length, (index) {
              final isSelected = _selectedIndex == index;

              return IntrinsicWidth(
                child: Container(
                  constraints: const BoxConstraints(minWidth: 80),
                  margin: const EdgeInsets.only(right: 12.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIndex = index; // Update selected tab index
                      });
                      widget.onTabChanged?.call(index);
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Tab Text
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                          child: Text(
                            tabs[index],
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 16,
                              color: isSelected ? Colors.black : Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        // Bottom Border
                        Container(
                          height: 2, // Border height
                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                          color: isSelected
                              ? Colors.teal // Teal color for selected tab
                              : const Color(0xFFD9D9D9), // Grey for other tabs
                        ),
                      ],
                    ),
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
