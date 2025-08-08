import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateScroll extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const DateScroll({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final DateTime today = DateTime.now();
    final DateTime startDate = today.subtract(Duration(days: today.weekday - 1)); // Start of the week (Monday)

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.blue[900],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            offset: const Offset(0, 4),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 7, // Show one week
          itemBuilder: (context, index) {
            final DateTime date = startDate.add(Duration(days: index));
            final String dayName = DateFormat('E').format(date); // "Mon", "Tue"
            final String dayNumber = DateFormat('d').format(date); // "16"

            final bool isSelected = date.day == selectedDate.day &&
                date.month == selectedDate.month &&
                date.year == selectedDate.year;

            return GestureDetector(
              onTap: () => onDateSelected(date),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.teal : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: isSelected ? Colors.teal.shade700 : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          dayNumber,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dayName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: isSelected ? Colors.white : Colors.grey.shade300,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
