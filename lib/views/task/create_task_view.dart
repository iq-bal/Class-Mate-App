import 'package:classmate/utils/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreateTaskView extends StatefulWidget {
  const CreateTaskView({super.key});
  @override
  State<CreateTaskView> createState() => _CreateTaskViewState();
}

class _CreateTaskViewState extends State<CreateTaskView> {
  DateTime? selectedDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  String? selectedCategory;

  final List<String> categories = [
    "Project",
    "Meeting",
    "Management",
    "Product",
    "Class Test"
  ];

  final List<Map<String, String>> allUsers = [
    {"name": "Alice", "avatar": "assets/images/avatar.png"},
    {"name": "Bob", "avatar": "assets/images/avatar.png"},
    {"name": "Charlie", "avatar": "assets/images/avatar.png"},
    {"name": "Diana", "avatar": "assets/images/avatar.png"},
  ];

  final List<Map<String, String>> selectedParticipants = [];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime
          ? (startTime ?? TimeOfDay.now())
          : (endTime ?? TimeOfDay.now()),
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          startTime = picked;
        } else {
          endTime = picked;
        }
      });
    }
  }

  String formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return 'Select Time';
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat.jm().format(dt); // Format as AM/PM
  }

  String formatDate(DateTime? date) {
    if (date == null) return 'Select Date';
    return DateFormat.yMMMd().format(date); // Format as "Jan 1, 2025"
  }

  void _openParticipantSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SizedBox(
          height: 400,
          child: Column(
            children: [
              const SizedBox(height: 16),
              const Text(
                "Select Participants",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: allUsers.length,
                  itemBuilder: (context, index) {
                    final user = allUsers[index];
                    final isSelected = selectedParticipants.contains(user);
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: AssetImage(user["avatar"]!),
                      ),
                      title: Text(user["name"]!),
                      trailing: isSelected
                          ? const Icon(Icons.check, color: Colors.teal)
                          : null,
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedParticipants.remove(user);
                          } else {
                            selectedParticipants.add(user);
                          }
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomAppBar(title: "Create Task"),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Title Input Section
                    _buildSection(
                      title: "Title",
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Enter task title",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Date Section
                    _buildSection(
                      title: "Date",
                      child: GestureDetector(
                        onTap: () => _selectDate(context),
                        child: AbsorbPointer(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: formatDate(selectedDate),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: const Icon(Icons.calendar_today,
                                  color: Colors.teal),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Category Section
                    _buildSection(
                      title: "Category",
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: categories.map((category) {
                          final isSelected = selectedCategory == category;
                          return ChoiceChip(
                            label: Text(
                              category,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.teal.shade800,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: Colors.teal,
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                  color: Colors.teal.shade200, width: 1),
                            ),
                            onSelected: (bool selected) {
                              setState(() {
                                selectedCategory = selected ? category : null;
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Time Section
                    _buildSection(
                      title: "Time",
                      child: Row(
                        children: [
                          // Start Time
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _selectTime(context, true),
                              child: AbsorbPointer(
                                child: TextField(
                                  decoration: InputDecoration(
                                    labelText: "Start Time", // Label inside the field
                                    labelStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal,
                                    ),
                                    hintText: formatTimeOfDay(startTime),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    prefixIcon: const Icon(Icons.access_time, color: Colors.teal),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // End Time
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _selectTime(context, false),
                              child: AbsorbPointer(
                                child: TextField(
                                  decoration: InputDecoration(
                                    labelText: "End Time", // Label inside the field
                                    labelStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal,
                                    ),
                                    hintText: formatTimeOfDay(endTime),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    prefixIcon: const Icon(Icons.access_time, color: Colors.teal),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Participants Section
                    _buildSection(
                      title: "Participants",
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: _openParticipantSelector,
                            child: const CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.add, color: Colors.teal),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ...selectedParticipants.map((participant) {
                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 12.0),
                                  child: CircleAvatar(
                                    radius: 24,
                                    backgroundImage:
                                    AssetImage(participant["avatar"]!),
                                  ),
                                ),
                                Positioned(
                                  top: -6,
                                  right: -6,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedParticipants.remove(participant);
                                      });
                                    },
                                    child: const CircleAvatar(
                                      radius: 12,
                                      backgroundColor: Colors.red,
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Create Task Button
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          print("Create Task Pressed");
                          print("Selected Category: $selectedCategory");
                          print("Date: ${formatDate(selectedDate)}");
                          print("Start Time: ${formatTimeOfDay(startTime)}");
                          print("End Time: ${formatTimeOfDay(endTime)}");
                          print("Participants: $selectedParticipants");
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          elevation: 5,
                          backgroundColor: Colors.teal,
                        ),
                        child: const Text(
                          "Create Task",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.w600, color: Colors.teal),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
