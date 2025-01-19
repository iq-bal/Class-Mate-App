import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  // Initialize notification channels and request permissions
  Future<void> initialize() async {
    // Request permission
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create notification channel for Android
    await _createNotificationChannel();

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  // Get FCM token
  Future<String?> getFCMToken() async {
    return await _firebaseMessaging.getToken();
  }

  // Create notification channel for Android
  Future<void> _createNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      'task_invitations', // Same as in backend
      'Task Invitations',
      description: 'Notifications for task invitations',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Received foreground message: ${message.notification?.title}');

    if (message.notification != null) {
      // Show local notification
      await _showLocalNotification(message);
    }
  }

  // Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'task_invitations',
      'Task Invitations',
      channelDescription: 'Notifications for task invitations',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      details,
      payload: message.data.toString(),
    );
  }

  // Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    // Parse the payload and navigate
    if (response.payload != null) {
      // Handle the notification payload
      print('Notification tapped with payload: ${response.payload}');
      // Navigate to appropriate screen based on payload
    }
  }

  // Handle notification tap when app is in background
  void _handleNotificationTap(RemoteMessage message) {
    print('Notification tapped in background state');
    // Navigate to appropriate screen based on message data
  }
}

// Handle background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling background message: ${message.messageId}');
}