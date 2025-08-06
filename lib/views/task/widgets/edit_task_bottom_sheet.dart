import 'package:classmate/controllers/task/task_controller.dart';
import 'package:classmate/core/helper_function.dart';
import 'package:classmate/entity/task_entity.dart';
import 'package:classmate/models/task/task_model.dart';
import 'package:classmate/views/task/widgets/participant_selector_modal.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditTaskBottomSheet extends StatefulWidget {
  final TaskModel task;

  const EditTaskBottomSheet({super.key, required this.task});

  @override
  State<EditTaskBottomSheet> createState() => _EditTaskBottomSheetState();
}

class _EditTaskBottomSheetState extends State<EditTaskBottomSheet> {
  late TextEditingController _titleController;
  late DateTime? _selectedDate;
  late TimeOfDay? _startTime;
  late TimeOfDay? _endTime;
  late String? _selectedCategory;
  late List<Map<String, String>> _selectedParticipants;
  List<Map<String, String>> _fetchedUsers = [];
  final TaskController _taskController = TaskController();

  final List<String> _categories = [
    "Project",
    "Meeting",
    "Management",
    "Product",
    "Class Test",
    "Work"
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _selectedDate = widget.task.date;
    
    // Parse start time
    if (widget.task.startTime != null) {
      final parts = widget.task.startTime!.split(':');
      if (parts.length == 2) {
        int hour = int.tryParse(parts[0]) ?? 0;
        int minute = int.tryParse(parts[1]) ?? 0;
        _startTime = TimeOfDay(hour: hour, minute: minute);
      } else {
        _startTime = null;
      }
    } else {
      _startTime = null;
    }
    
    // Parse end time
    if (widget.task.endTime != null) {
      final parts = widget.task.endTime!.split(':');
      if (parts.length == 2) {
        int hour = int.tryParse(parts[0]) ?? 0;
        int minute = int.tryParse(parts[1]) ?? 0;
        _endTime = TimeOfDay(hour: hour, minute: minute);
      } else {
        _endTime = null;
      }
    } else {
      _endTime = null;
    }
    
    _selectedCategory = widget.task.category?.toUpperCase();
    
    // Initialize participants from the task
    _selectedParticipants = widget.task.participants?.map((participant) => {
      "id": participant.id ?? "",
      "name": "Participant", // Default name since TaskParticipant doesn't have a name property
      "avatar": participant.profilePicture ?? "assets/images/avatar.png",
    }).toList() ?? [];
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime
          ? (_startTime ?? TimeOfDay.now())
          : (_endTime ?? TimeOfDay.now()),
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return 'Select Time';
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat.jm().format(dt);
  }

  Future<void> _openParticipantSelector() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    await _taskController.getUsers();

    Navigator.pop(context);

    await Future.delayed(const Duration(milliseconds: 100)); // Add delay

    if (_taskController.stateNotifier.value == TaskState.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_taskController.errorMessage ?? 'Error fetching users')),
      );
      return;
    }

    _fetchedUsers = _taskController.users
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
          allUsers: _fetchedUsers,
          selectedParticipants: _selectedParticipants,
          onParticipantSelected: (user) {
            setState(() {
              _selectedParticipants.add(user);
            });
          },
          onParticipantRemoved: (user) {
            setState(() {
              _selectedParticipants.remove(user);
            });
          },
        );
      },
    );
  }

  void _updateTask() async {
    if (_titleController.text.isEmpty || _selectedDate == null || 
        _startTime == null || _endTime == null || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final updatedTask = TaskModel(
        title: _titleController.text,
        date: _selectedDate,
        startTime: '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}',
        endTime: '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}',
        category: _selectedCategory?.toLowerCase(),
        participants: _selectedParticipants
            .map((participant) => TaskParticipant(
                  id: participant["id"],
                  profilePicture: participant["avatar"],
                ))
            .toList(),
      );

      await _taskController.updateTask(widget.task.id!, updatedTask);

      // Close loading dialog
      Navigator.pop(context);

      if (_taskController.stateNotifier.value == TaskState.success) {
        await HelperFunction.showNotification(
          "Task",
          "Your task has been updated successfully!"
        );
        Navigator.pop(context); // Close the bottom sheet
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_taskController.errorMessage ?? 'Failed to update task')),
        );
      }
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Edit Task',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _titleController,
              label: 'Title',
              icon: Icons.title,
            ),
            const SizedBox(height: 15),
            _buildDatePicker(),
            const SizedBox(height: 15),
            _buildCategorySelector(),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _buildTimePicker(
                    label: 'Start Time',
                    time: _startTime,
                    isStartTime: true,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTimePicker(
                    label: 'End Time',
                    time: _endTime,
                    isStartTime: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            _buildParticipantsSection(),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _updateTask,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Update Task',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.teal),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.teal, width: 2),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.teal),
            const SizedBox(width: 10),
            Text(
              _selectedDate != null
                  ? DateFormat('EEE, MMM dd, yyyy').format(_selectedDate!)
                  : 'Select Date',
              style: TextStyle(
                color: _selectedDate != null ? Colors.black : Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories.map((category) {
            final isSelected = _selectedCategory == category.toUpperCase();
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category.toUpperCase();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.teal : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTimePicker({
    required String label,
    required TimeOfDay? time,
    required bool isStartTime,
  }) {
    return InkWell(
      onTap: () => _selectTime(context, isStartTime),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: Colors.teal),
            const SizedBox(width: 10),
            Text(
              time != null ? _formatTimeOfDay(time) : label,
              style: TextStyle(
                color: time != null ? Colors.black : Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Participants',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: _openParticipantSelector,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.teal,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Add Participant',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (_selectedParticipants.isNotEmpty) const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedParticipants.map((participant) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundImage: AssetImage(participant["avatar"]!),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          participant["name"]!,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedParticipants.remove(participant);
                            });
                          },
                          child: const Icon(Icons.close, size: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}