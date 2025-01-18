import 'package:classmate/utils/custom_app_bar.dart';
import 'package:classmate/views/task/widgets/category_selector.dart';
import 'package:classmate/views/task/widgets/date_picker_field.dart';
import 'package:classmate/views/task/widgets/participant_selector_modal.dart';
import 'package:classmate/views/task/widgets/participants_selector.dart';
import 'package:classmate/views/task/widgets/time_picker_field.dart';
import 'package:classmate/views/task/widgets/title_input.dart';
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
    return DateFormat.jm().format(dt);
  }


  void _openParticipantSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ParticipantSelectorModal(
          allUsers: allUsers,
          selectedParticipants: selectedParticipants,
          onParticipantSelected: (user) {
            setState(() {
              selectedParticipants.add(user);
            });
          },
          onParticipantRemoved: (user) {
            setState(() {
              selectedParticipants.remove(user);
            });
          },
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
                    _buildSection(title: "Title", child: const TitleInput()),
                    const SizedBox(height: 20),
                    _buildSection(
                      title: "Date",
                      child: DatePickerField(
                        selectedDate: selectedDate,
                        onTap: () => _selectDate(context),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      title: "Category",
                      child: CategorySelector(
                        categories: categories,
                        selectedCategory: selectedCategory,
                        onSelected: (value) {
                          setState(() => selectedCategory = value);
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildSection(
                      title: "Time",
                      child: Row(
                        children: [
                          Expanded(
                            child: TimePickerField(
                              labelText: startTime != null
                                  ? "Start: ${formatTimeOfDay(startTime)}"
                                  : "Start Time",
                              selectedTime: startTime,
                              onTap: () => _selectTime(context, true),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TimePickerField(
                              labelText: endTime != null
                                  ? "End: ${formatTimeOfDay(endTime)}"
                                  : "End Time",
                              selectedTime: endTime,
                              onTap: () => _selectTime(context, false),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      title: "Participants",
                      child: ParticipantsSelector(
                        participants: selectedParticipants,
                        onAddParticipant: () => _openParticipantSelector(),
                        onRemoveParticipant: (participant) {
                          setState(() {
                            selectedParticipants.remove(participant);
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          print("Create Task Pressed");
                          print("Category: $selectedCategory");
                          print("Date: ${DateFormat.yMMMd().format(selectedDate ?? DateTime.now())}");
                          print("Start Time: $startTime");
                          print("End Time: $endTime");
                          print("Participants: $selectedParticipants");
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          backgroundColor: Colors.teal,
                        ),
                        child: const Text(
                          "Create Task",
                          style: TextStyle(fontSize: 18, color: Colors.white),
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
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
