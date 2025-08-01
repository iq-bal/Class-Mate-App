import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsIOS =
  DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

class HelperFunction {
  static String getFirstTwoLettersUppercase(String input) {
    if (input.isEmpty) {
      return '';
    }
    String firstTwoLetters = input.length >= 2 ? input.substring(0, 2) : input;
    return firstTwoLetters.toUpperCase();
  }
  static String formatTimestamp(String timestamp) {
    int parsedTimestamp = int.tryParse(timestamp) ?? 0;
    DateTime date = DateTime.fromMillisecondsSinceEpoch(parsedTimestamp);
    return DateFormat('MMM d, yyyy').format(date);
  }

  static String formatISODate(String isoDateString) {
    try {
      DateTime date = DateTime.parse(isoDateString);
      return DateFormat('MMM d, yyyy').format(date);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  static String cleanTime(String time) {
    // Use a regex to remove any alphabets (both uppercase and lowercase)
    final regex = RegExp(r'[a-zA-Z]');
    return time.replaceAll(regex, '').trim(); // Trim spaces after removing alphabets
  }


  static String getAttendanceFeedback(double attendancePercentage) {
    if (attendancePercentage >= 0.9) {
      return "Excellent attendance! Keep it up!";
    } else if (attendancePercentage >= 0.75) {
      return "Great attendance! Try to maintain this level.";
    } else if (attendancePercentage >= 0.6) {
      return "You're doing okay, but there's room for improvement.";
    } else {
      return "Your attendance is low. Make an effort to attend more classes.";
    }
  }




  static Future<void> showNotification(String title, String body) async {
    try {
      const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
        'assignment_channel',
        'Assignments',
        channelDescription: 'Notifications for assignment submissions',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true, // Ensure sound is enabled
        enableVibration: true, // Ensure vibration is enabled
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
      );

      // int notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000; // Unique ID
      int notificationId = 0;
      await flutterLocalNotificationsPlugin.show(
        notificationId,
        title,
        body,
        notificationDetails,
      );
    } catch (e) {
      print('Error showing notification: $e');
    }
  }

}
