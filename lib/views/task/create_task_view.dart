import 'package:classmate/utils/custom_app_bar.dart';
import 'package:classmate/views/task/widgets/category_selector.dart';
import 'package:classmate/views/task/widgets/date_picker_field.dart';
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



  void _openParticipantSelector() {
    TextEditingController searchController = TextEditingController();
    List<Map<String, String>> filteredUsers = List.from(allUsers);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            void _filterUsers(String query) {
              setState(() {
                if (query.isEmpty) {
                  filteredUsers = List.from(allUsers);
                } else {
                  filteredUsers = allUsers
                      .where((user) =>
                      user["name"]!.toLowerCase().contains(query.toLowerCase()))
                      .toList();
                }
              });
            }

            return Scaffold(
              backgroundColor: Colors.white,
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Header with Close Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Select Participants",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.check, color: Colors.teal),
                          ),
                        ],
                      ),
                      const Divider(),

                      // Search Field
                      TextField(
                        controller: searchController,
                        onChanged: _filterUsers,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search, color: Colors.teal),
                          hintText: "Search participants",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade200,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Participant List
                      Expanded(
                        child: filteredUsers.isNotEmpty
                            ? ListView.builder(
                          itemCount: filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = filteredUsers[index];
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
                                // Reflect the changes immediately in the parent state
                                this.setState(() {});
                              },
                            );
                          },
                        )
                            : const Center(
                          child: Text(
                            "No participants found",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
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
                              labelText: "Start Time",
                              selectedTime: startTime,
                              onTap: () => _selectTime(context, true),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TimePickerField(
                              labelText: "End Time",
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
