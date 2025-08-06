import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:classmate/controllers/course_detail_teacher/reschedule_controller.dart';
import 'package:classmate/models/create_course/schedule_model.dart';

class RescheduleModal extends StatefulWidget {
  final String scheduleId;
  final String courseId;
  final ScheduleModel currentSchedule;
  final VoidCallback onScheduleUpdated;

  const RescheduleModal({
    super.key,
    required this.scheduleId,
    required this.courseId,
    required this.currentSchedule,
    required this.onScheduleUpdated,
  });

  @override
  State<RescheduleModal> createState() => _RescheduleModalState();
}

class _RescheduleModalState extends State<RescheduleModal> {
  late String selectedDay;
  late TextEditingController startTimeController;
  late TextEditingController endTimeController;
  late TextEditingController roomController;
  late TextEditingController sectionController;
  


  @override
  void initState() {
    super.initState();
    // Initialize with current schedule values
    selectedDay = widget.currentSchedule.day;
    startTimeController = TextEditingController(text: widget.currentSchedule.startTime);
    endTimeController = TextEditingController(text: widget.currentSchedule.endTime);
    roomController = TextEditingController(text: widget.currentSchedule.roomNumber);
    sectionController = TextEditingController(text: widget.currentSchedule.section);
  }
  
  @override
  void dispose() {
    roomController.dispose();
    sectionController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RescheduleController(),
      child: Consumer<RescheduleController>(
        builder: (context, controller, child) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: DraggableScrollableSheet(
              initialChildSize: 0.8,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Handle bar
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      
                      // Header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Reschedule Course',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                      ),
                      
                      const Divider(),
                      
                      // Form content
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Current schedule info
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.blue[200]!),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Current Schedule',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text('Day: ${widget.currentSchedule.day}'),
                                    Text('Time: ${widget.currentSchedule.startTime} - ${widget.currentSchedule.endTime}'),
                                    Text('Room: ${widget.currentSchedule.roomNumber}'),
                                    Text('Section: ${widget.currentSchedule.section}'),
                                  ],
                                ),
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // Day selection
                              const Text(
                                'Select Day',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                value: selectedDay,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 16,
                                  ),
                                ),
                                items: controller.availableDays.map((day) {
                                  return DropdownMenuItem(
                                    value: day,
                                    child: Text(day),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      selectedDay = value;
                                    });
                                  }
                                },
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Time selection
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Start Time',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        TextFormField(
                          controller: startTimeController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                            hintText: 'Enter start time (e.g., 10:00 AM)',
                          ),
                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'End Time',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        TextFormField(
                          controller: endTimeController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                            hintText: 'Enter end time (e.g., 12:00 PM)',
                          ),
                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Room number
                              const Text(
                                'Room Number',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: roomController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 16,
                                  ),
                                  hintText: 'Enter room number',
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Section
                              const Text(
                                'Section',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: sectionController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 16,
                                  ),
                                  hintText: 'Enter section',
                                ),
                              ),
                              
                              // Error message
                              if (controller.errorMessage != null) ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.red[200]!),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.error, color: Colors.red[600], size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          controller.errorMessage!,
                                          style: TextStyle(color: Colors.red[600]),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              
                              const SizedBox(height: 24),
                              
                              // Action buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: controller.isLoading 
                                          ? null 
                                          : () => Navigator.pop(context),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text('Cancel'),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: controller.isLoading 
                                          ? null 
                                          : () => _handleReschedule(context, controller),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: controller.isLoading
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              ),
                                            )
                                          : const Text('Update Schedule'),
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Info note
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.amber[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.amber[200]!),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.info, color: Colors.amber[600], size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'All enrolled students will be notified about the schedule change via push notifications and real-time updates.',
                                        style: TextStyle(
                                          color: Colors.amber[800],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
  
  Future<void> _handleReschedule(BuildContext context, RescheduleController controller) async {
    final success = await controller.updateSchedule(
      scheduleId: widget.scheduleId,
      day: selectedDay,
      startTime: startTimeController.text.trim(),
      endTime: endTimeController.text.trim(),
      roomNumber: roomController.text.trim(),
      section: sectionController.text.trim(),
      courseId: widget.courseId,
    );
    
    if (success && context.mounted) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Schedule updated successfully! Students have been notified.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
      
      // Call the callback to refresh the parent view
      widget.onScheduleUpdated();
      
      // Close the modal
      Navigator.pop(context);
    }
  }
}