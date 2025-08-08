import 'package:classmate/controllers/task/task_controller.dart';
import 'package:classmate/core/helper_function.dart';
import 'package:classmate/entity/task_entity.dart';
import 'package:classmate/models/task/task_model.dart';
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

  String? taskTitle;


  final TaskController taskController = TaskController();

  final List<String> categories = [
    "Project",
    "Meeting",
    "Management",
    "Product",
    "Class Test"
  ];

  late List<Map<String, String>> fetchedUsers = [];
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

  void _openParticipantSelector() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    await taskController.getUsers();

    Navigator.pop(context);

    await Future.delayed(const Duration(milliseconds: 100)); // Add delay

    if (taskController.stateNotifier.value == TaskState.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(taskController.errorMessage ?? 'Error fetching users')),
      );
      return;
    }

    fetchedUsers = taskController.users
        ?.map((user) => {
      "id": user.id ?? "",
      "name": user.name ?? "Unknown",
      "avatar": user.profilePicture ?? "assets/images/avatar.png",
    })
        .toList() ??
        [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ParticipantSelectorModal(
          allUsers: fetchedUsers,
          selectedParticipants: selectedParticipants,
          onParticipantSelected: (user) {
            setState(() {
              // Check if participant is not already selected by ID
              if (!selectedParticipants.any((participant) => participant["id"] == user["id"])) {
                selectedParticipants.add(user);
              }
            });
          },
          onParticipantRemoved: (user) {
            setState(() {
              selectedParticipants.removeWhere((participant) => participant["id"] == user["id"]);
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
                    _buildSection(
                      title: "Title",
                      child: TitleInput(
                        onChanged: (value) {
                          setState(() {
                            taskTitle = value;
                          });
                        },
                      ),
                    ),
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
                            selectedParticipants.removeWhere((p) => p["id"] == participant["id"]);
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          // Validate required fields
                          if (taskTitle == null || taskTitle!.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter a task title')),
                            );
                            return;
                          }
                          if (selectedDate == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please select a date')),
                            );
                            return;
                          }
                          if (selectedCategory == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please select a category')),
                            );
                            return;
                          }
                          if (startTime == null || endTime == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please select start and end times')),
                            );
                            return;
                          }

                          // Show loading dialog
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const Center(child: CircularProgressIndicator()),
                          );

                          try {
                            await taskController.createTask(TaskModel(
                              title: taskTitle!,
                              date: selectedDate,
                              startTime: startTime?.format(context).toLowerCase(),
                              endTime: endTime?.format(context).toLowerCase(),
                              category: selectedCategory?.toLowerCase(),
                              participants: selectedParticipants
                                  .map((participant) => TaskParticipant(
                                        id: participant["id"],
                                        profilePicture: participant["avatar"],
                                      ))
                                  .toList(),
                            )); 

                            // Close loading dialog
                            if (mounted) Navigator.pop(context);
                            
                            if (taskController.stateNotifier.value == TaskState.success) {
                              await HelperFunction.showNotification(
                                  "Task",
                                  "Your task has been created successfully!"
                              );
                              // Return true to indicate successful creation
                              if (mounted) Navigator.pop(context, true);
                            } else {
                              await HelperFunction.showNotification(
                                  "Task",
                                  "Task creation failed"
                              );
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(taskController.errorMessage ?? 'Failed to create task'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            // Close loading dialog
                            if (mounted) Navigator.pop(context);
                            
                            await HelperFunction.showNotification(
                                "Task",
                                "Task creation failed"
                            );
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to create task: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
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
