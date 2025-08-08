import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:classmate/config/app_config.dart';
import 'package:classmate/core/token_storage.dart';

class SocketNotificationService {
  static final SocketNotificationService _instance = SocketNotificationService._internal();
  factory SocketNotificationService() => _instance;
  SocketNotificationService._internal();

  IO.Socket? _socket;
  bool _isConnected = false;
  final List<String> _subscribedCourses = [];
  
  // Callbacks for different notification types
  Function(Map<String, dynamic>)? onCourseRescheduled;
  Function(Map<String, dynamic>)? onGeneralNotification;
  Function(bool)? onConnectionStatusChanged;

  bool get isConnected => _isConnected;
  List<String> get subscribedCourses => List.unmodifiable(_subscribedCourses);

  /// Initialize Socket.IO connection
  Future<void> initialize() async {
    if (_socket != null && _isConnected) {
      return; // Already connected
    }

    try {
      final token = await TokenStorage().retrieveAccessToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      _socket = IO.io(
        AppConfig.socketBaseUrl, // Use socket base URL for notifications
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .setAuth({
              'token': token,
            })
            .build(),
      );
      _setupEventListeners();
      _socket!.connect();
    } catch (e) {
      print('Failed to initialize notification service: $e');
      rethrow;
    }
  }

  /// Setup Socket.IO event listeners
  void _setupEventListeners() {
    if (_socket == null) return;

    // Connection events
    _socket!.onConnect((_) {
      print('Connected to notification server');
      _isConnected = true;
      onConnectionStatusChanged?.call(true);
      
      // Re-subscribe to courses after reconnection
      for (final courseId in _subscribedCourses) {
        _socket!.emit('subscribeToCourse', {'course_id': courseId});
      }
    });

    _socket!.onDisconnect((_) {
      print('Disconnected from notification server');
      _isConnected = false;
      onConnectionStatusChanged?.call(false);
    });

    _socket!.onConnectError((error) {
      print('Connection error: $error');
      _isConnected = false;
      onConnectionStatusChanged?.call(false);
    });

    // Course reschedule events
    _socket!.on('courseRescheduled', (data) {
      print('Course rescheduled event received: $data');
      if (data is Map<String, dynamic>) {
        onCourseRescheduled?.call(data);
        _handleCourseRescheduled(data);
      }
    });

    // General notifications
    _socket!.on('notification', (data) {
      print('General notification received: $data');
      if (data is Map<String, dynamic>) {
        onGeneralNotification?.call(data);
        _handleGeneralNotification(data);
      }
    });
  }

  /// Handle course reschedule events
  void _handleCourseRescheduled(Map<String, dynamic> data) {
    try {
      final courseId = data['courseId'] as String?;
      final courseName = data['courseName'] as String?;
      final newSchedule = data['newSchedule'] as Map<String, dynamic>?;
      final oldSchedule = data['oldSchedule'] as Map<String, dynamic>?;
      
      if (courseId != null && courseName != null && newSchedule != null) {
        // You can add local notification display logic here
        print('Course $courseName has been rescheduled');
        print('New schedule: $newSchedule');
        if (oldSchedule != null) {
          print('Old schedule: $oldSchedule');
        }
      }
    } catch (e) {
      print('Error handling course reschedule event: $e');
    }
  }

  /// Handle general notifications
  void _handleGeneralNotification(Map<String, dynamic> data) {
    try {
      final type = data['type'] as String?;
      final title = data['title'] as String?;
      final message = data['message'] as String?;
      
      if (type == 'course_reschedule') {
        print('Course reschedule notification: $title - $message');
        // Handle course reschedule notification
        final notificationData = data['data'] as Map<String, dynamic>?;
        if (notificationData != null) {
          final courseId = notificationData['courseId'] as String?;
          final newSchedule = notificationData['newSchedule'] as Map<String, dynamic>?;
          
          if (courseId != null && newSchedule != null) {
            // You can trigger UI updates or local notifications here
            print('Course $courseId schedule updated: $newSchedule');
          }
        }
      }
    } catch (e) {
      print('Error handling general notification: $e');
    }
  }

  /// Subscribe to course notifications
  void subscribeToCourse(String courseId) {
    if (_socket == null || !_isConnected) {
      print('Socket not connected, cannot subscribe to course $courseId');
      return;
    }

    if (!_subscribedCourses.contains(courseId)) {
      _subscribedCourses.add(courseId);
      _socket!.emit('subscribeToCourse', {'course_id': courseId});
      print('Subscribed to course: $courseId');
    }
  }

  /// Unsubscribe from course notifications
  void unsubscribeFromCourse(String courseId) {
    if (_socket == null || !_isConnected) {
      print('Socket not connected, cannot unsubscribe from course $courseId');
      return;
    }

    if (_subscribedCourses.contains(courseId)) {
      _subscribedCourses.remove(courseId);
      _socket!.emit('unsubscribeFromCourse', {'course_id': courseId});
      print('Unsubscribed from course: $courseId');
    }
  }

  /// Subscribe to multiple courses
  void subscribeToMultipleCourses(List<String> courseIds) {
    for (final courseId in courseIds) {
      subscribeToCourse(courseId);
    }
  }

  /// Unsubscribe from all courses
  void unsubscribeFromAllCourses() {
    final coursesToUnsubscribe = List<String>.from(_subscribedCourses);
    for (final courseId in coursesToUnsubscribe) {
      unsubscribeFromCourse(courseId);
    }
  }

  /// Set callback for course reschedule events
  void setCourseRescheduledCallback(Function(Map<String, dynamic>) callback) {
    onCourseRescheduled = callback;
  }

  /// Set callback for general notifications
  void setGeneralNotificationCallback(Function(Map<String, dynamic>) callback) {
    onGeneralNotification = callback;
  }

  /// Set callback for connection status changes
  void setConnectionStatusCallback(Function(bool) callback) {
    onConnectionStatusChanged = callback;
  }

  /// Disconnect from the notification server
  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _isConnected = false;
      _subscribedCourses.clear();
      print('Disconnected from notification server');
    }
  }

  /// Reconnect to the notification server
  Future<void> reconnect() async {
    disconnect();
    await initialize();
  }

  /// Check if subscribed to a specific course
  bool isSubscribedToCourse(String courseId) {
    return _subscribedCourses.contains(courseId);
  }

  /// Get connection status
  bool getConnectionStatus() {
    return _isConnected;
  }

  /// Dispose the service
  void dispose() {
    disconnect();
    onCourseRescheduled = null;
    onGeneralNotification = null;
    onConnectionStatusChanged = null;
  }
}