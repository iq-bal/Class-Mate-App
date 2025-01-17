import 'package:flutter/material.dart';

class HeaderWithDateScroll extends StatelessWidget {
  final VoidCallback onBackPressed;
  final int selectedDateIndex;
  final Function(int) onDateSelected;

  const HeaderWithDateScroll({
    super.key,
    required this.onBackPressed,
    required this.selectedDateIndex,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Section
        Container(
          color: Colors.blue[900],
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                    onPressed: onBackPressed,
                  ),
                  const Spacer(),
                  const Text(
                    "Create Task",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      Icons.calendar_today,
                      color: Colors.white,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ),

        // Date Scroll Section
        Container(
          height: 80,
          color: Colors.blue[900],
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 7,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => onDateSelected(index),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Column(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: index == selectedDateIndex
                              ? Colors.teal
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Center(
                          child: Text(
                            "16",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: index == selectedDateIndex
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Mon",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
