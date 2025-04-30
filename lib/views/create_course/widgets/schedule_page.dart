import 'package:flutter/material.dart';
import 'package:classmate/models/create_course/schedule_model.dart';

import '../../../controllers/create_course/schedule_controller.dart';

class SchedulePage extends StatefulWidget {
  final String courseId;
  final ScheduleController scheduleController;

  const SchedulePage({super.key, required this.courseId, required this.scheduleController});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final _formKey = GlobalKey<FormState>();

  String? selectedDay;
  final TextEditingController sectionController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();
  final TextEditingController roomNumberController = TextEditingController();

  final List<String> daysOfWeek = [
    'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'
  ];

  // List to store multiple schedules
  List<ScheduleModel> schedules = [];

  // Submit the form and append the schedule
  void _submit() {
    if (_formKey.currentState!.validate()) {
      final newSchedule = ScheduleModel(
        id: '',  // You can generate an ID or leave it empty for now
        courseId: widget.courseId,  // Use the passed courseId
        day: selectedDay ?? '',
        section: sectionController.text.trim(),
        startTime: startTimeController.text.trim(),
        endTime: endTimeController.text.trim(),
        roomNumber: roomNumberController.text.trim(),
      );

      // Call the controller's method to save the schedule to the backend
      widget.scheduleController.createSchedule(newSchedule);

      // Append the schedule to the list
      setState(() {
        schedules.add(newSchedule); // Add the newly created schedule to the list
      });

      // Clear the form after submission
      sectionController.clear();
      startTimeController.clear();
      endTimeController.clear();
      roomNumberController.clear();
      selectedDay = null;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Schedule added successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const SizedBox(height: 10),
                _buildDropdownDay(),
                const SizedBox(height: 20),
                _buildTextField(controller: sectionController, hint: 'Section (e.g., A1)', validatorMessage: 'Section is required'),
                const SizedBox(height: 20),
                _buildTextField(controller: startTimeController, hint: 'Start Time (e.g., 10:00 AM)', validatorMessage: 'Start time is required'),
                const SizedBox(height: 20),
                _buildTextField(controller: endTimeController, hint: 'End Time (e.g., 12:00 PM)', validatorMessage: 'End time is required'),
                const SizedBox(height: 20),
                _buildTextField(controller: roomNumberController, hint: 'Room Number (e.g., 305)', validatorMessage: 'Room number is required'),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Save Schedule', style: TextStyle(fontSize: 18)),
                ),

                const SizedBox(height: 30),

                // Display the list of added schedules
                const Text(
                  'Added Schedules:',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                // Display the added schedules in a ListView
                ...schedules.map((schedule) {
                  return ListTile(
                    title: Text("${schedule.day} - ${schedule.section}"),
                    subtitle: Text("Time: ${schedule.startTime} - ${schedule.endTime}, Room: ${schedule.roomNumber}"),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Dropdown for selecting day of the week
  Widget _buildDropdownDay() {
    return DropdownButtonFormField<String>(
      value: selectedDay,
      hint: const Text('Select Day'),
      items: daysOfWeek.map((day) {
        return DropdownMenuItem<String>(
          value: day,
          child: Text(day),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedDay = value;
        });
      },
      validator: (value) => value == null ? 'Please select a day' : null,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.blue.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // Common text field builder
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required String validatorMessage,
  }) {
    return TextFormField(
      controller: controller,
      validator: (value) => value == null || value.isEmpty ? validatorMessage : null,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.blue.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
