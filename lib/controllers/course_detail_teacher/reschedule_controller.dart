import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:classmate/models/create_course/schedule_model.dart';
import 'package:classmate/services/course_detail_teacher/reschedule_service.dart';

class RescheduleController extends ChangeNotifier {
  final RescheduleService _rescheduleService = RescheduleService();
  
  bool _isLoading = false;
  String? _errorMessage;
  ScheduleModel? _currentSchedule;
  
  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ScheduleModel? get currentSchedule => _currentSchedule;
  
  // Available days for scheduling
  final List<String> availableDays = [
    'Monday',
    'Tuesday', 
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  
  // Available time slots in 24-hour format
  final List<String> _timeSlots24Hour = [
    '08:00',
    '08:30',
    '09:00',
    '09:30',
    '10:00',
    '10:30',
    '11:00',
    '11:30',
    '12:00',
    '12:30',
    '13:00',
    '13:30',
    '14:00',
    '14:30',
    '15:00',
    '15:30',
    '16:00',
    '16:30',
    '17:00',
    '17:30',
    '18:00'
  ];
  
  // Convert 24-hour format to AM/PM format
  String _formatTimeToAmPm(String time24) {
    try {
      final parts = time24.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final now = DateTime.now();
      final dt = DateTime(now.year, now.month, now.day, hour, minute);
      return DateFormat.jm().format(dt);
    } catch (e) {
      return time24; // Return original if parsing fails
    }
  }
  
  // Convert AM/PM format back to 24-hour format
  String _formatTimeTo24Hour(String timeAmPm) {
    try {
      final dateTime = DateFormat.jm().parse(timeAmPm);
      return DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      // If parsing fails, return the original string
      return timeAmPm;
    }
  }
  
  // Available time slots in AM/PM format
  List<String> get availableTimeSlots {
    return _timeSlots24Hour.map((time) => _formatTimeToAmPm(time)).toList();
  }
  
  /// Load current schedule details
  Future<void> loadSchedule(String scheduleId) async {
    _setLoading(true);
    _clearError();
    
    try {
      _currentSchedule = await _rescheduleService.getSchedule(scheduleId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load schedule: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Update course schedule
  Future<bool> updateSchedule({
    required String scheduleId,
    required String day,
    required String startTime,
    required String endTime,
    required String roomNumber,
    required String section,
    required String courseId,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      // Validate input
      if (!_validateScheduleInput(day, startTime, endTime, roomNumber, section)) {
        return false;
      }
      
      final newSchedule = ScheduleModel(
        id: scheduleId,
        courseId: courseId,
        day: day,
        section: section,
        startTime: startTime,
        endTime: endTime,
        roomNumber: roomNumber,
      );
      
      final updatedSchedule = await _rescheduleService.updateSchedule(
        scheduleId: scheduleId,
        scheduleData: newSchedule,
      );
      
      _currentSchedule = updatedSchedule;
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update schedule: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Validate schedule input
  bool _validateScheduleInput(
    String day,
    String startTime,
    String endTime,
    String roomNumber,
    String section,
  ) {
    // Check if day is valid
    if (!availableDays.contains(day)) {
      _setError('Invalid day selected');
      return false;
    }
    
    // Validate time format and parse times
    DateTime? startDateTime;
    DateTime? endDateTime;
    
    try {
      // Try to parse as AM/PM format first
      startDateTime = DateFormat.jm().parse(startTime.trim());
    } catch (e) {
      try {
        // Try alternative AM/PM formats
        startDateTime = DateFormat('h:mm a').parse(startTime.trim());
      } catch (e2) {
        try {
          // Try to parse as 24-hour format
          final parts = startTime.trim().split(':');
          if (parts.length == 2) {
            final hour = int.parse(parts[0]);
            final minute = int.parse(parts[1]);
            if (hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59) {
              final now = DateTime.now();
              startDateTime = DateTime(now.year, now.month, now.day, hour, minute);
            }
          }
        } catch (e3) {
          _setError('Invalid start time format. Use format like "11:00 AM" or "11:00"');
          return false;
        }
      }
    }
    
    try {
      // Try to parse as AM/PM format first
      endDateTime = DateFormat.jm().parse(endTime.trim());
    } catch (e) {
      try {
        // Try alternative AM/PM formats
        endDateTime = DateFormat('h:mm a').parse(endTime.trim());
      } catch (e2) {
        try {
          // Try to parse as 24-hour format
          final parts = endTime.trim().split(':');
          if (parts.length == 2) {
            final hour = int.parse(parts[0]);
            final minute = int.parse(parts[1]);
            if (hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59) {
              final now = DateTime.now();
              endDateTime = DateTime(now.year, now.month, now.day, hour, minute);
            }
          }
        } catch (e3) {
          _setError('Invalid end time format. Use format like "11:45 AM" or "11:45"');
          return false;
        }
      }
    }
    
    if (startDateTime == null) {
      _setError('Invalid start time format. Use format like "10:00 AM" or "10:00"');
      return false;
    }
    
    if (endDateTime == null) {
      _setError('Invalid end time format. Use format like "12:00 PM" or "12:00"');
      return false;
    }
    
    // Check if start time is before end time
    if (startDateTime.isAtSameMomentAs(endDateTime) || startDateTime.isAfter(endDateTime)) {
      _setError('Start time must be before end time');
      return false;
    }
    
    // Check if room number is not empty
    if (roomNumber.trim().isEmpty) {
      _setError('Room number cannot be empty');
      return false;
    }
    
    // Check if section is not empty
    if (section.trim().isEmpty) {
      _setError('Section cannot be empty');
      return false;
    }
    
    return true;
  }
  
  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  /// Set error message
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }
  
  /// Clear error message
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  /// Reset controller state
  void reset() {
    _isLoading = false;
    _errorMessage = null;
    _currentSchedule = null;
    notifyListeners();
  }
}