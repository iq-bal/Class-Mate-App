import 'package:classmate/controllers/course_detail_teacher/course_detail_teacher_controller.dart';
import 'package:flutter/material.dart';

class CreateClassTestModal extends StatelessWidget {
  final String courseId;
  final VoidCallback onClassTestCreated;

  const CreateClassTestModal({
    super.key,
    required this.courseId,
    required this.onClassTestCreated,
  });

  @override
  Widget build(BuildContext context) {
    final CourseDetailTeacherController courseDetailTeacherController = CourseDetailTeacherController();

    // Controllers for user input fields
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController dateController = TextEditingController();
    final TextEditingController durationController = TextEditingController();
    final TextEditingController totalMarksController = TextEditingController();

    void createClassTest(String courseId, String title, String description, String date, int duration, int totalMarks) {
      courseDetailTeacherController.createClassTest(courseId, title, description, date, duration, totalMarks);
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Modal Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Create New Class Test',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Title Field
          const Text(
            'Title',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: titleController,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Description Field
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),

          // Date Field
          const Text(
            'Test Date',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: dateController,
            readOnly: true,
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
              );
              if (pickedDate != null) {
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (pickedTime != null) {
                  final DateTime fullDateTime = DateTime(
                    pickedDate.year,
                    pickedDate.month,
                    pickedDate.day,
                    pickedTime.hour,
                    pickedTime.minute,
                  );
                  dateController.text = fullDateTime.toIso8601String();
                }
              }
            },
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.black),
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.calendar_today, color: Colors.black),
              hintText: 'Select Test Date & Time',
              hintStyle: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Duration and Total Marks Row
          Row(
            children: [
              // Duration Field
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Duration (minutes)',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: durationController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        hintText: 'e.g., 120',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Total Marks Field
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Marks',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: totalMarksController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        hintText: 'e.g., 100',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Done Button
          Center(
            child: ElevatedButton(
              onPressed: () {
                final String title = titleController.text.trim();
                final String description = descriptionController.text.trim();
                final String date = dateController.text.trim();
                final String durationText = durationController.text.trim();
                final String totalMarksText = totalMarksController.text.trim();

                // Validation: Ensure all fields are filled
                if (title.isEmpty || description.isEmpty || date.isEmpty || durationText.isEmpty || totalMarksText.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                  return;
                }

                final int? duration = int.tryParse(durationText);
                final int? totalMarks = int.tryParse(totalMarksText);

                if (duration == null || totalMarks == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Duration and Total Marks must be valid numbers')),
                  );
                  return;
                }

                // Call createClassTest function if validation is successful
                createClassTest(courseId, title, description, date, duration, totalMarks);
                onClassTestCreated();
                Navigator.pop(context); // Close the modal after class test creation
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 120),
              ),
              child: const Text(
                'Done',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}