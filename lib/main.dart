import 'package:classmate/core/authentication_handler.dart';
import 'package:classmate/controllers/authentication/auth_controller.dart';
import 'package:classmate/providers/auth_provider.dart';
import 'package:classmate/services/authentication/auth_service.dart';
import 'package:classmate/services/fcm_token_service.dart';
import 'package:classmate/services/notification_service.dart';
import 'package:classmate/views/authentication/landing.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final notificationService = NotificationService();
  await notificationService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
          create: (_) => AuthController(
            AuthService(),
            NotificationService(),
            FCMTokenService(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Class Mate',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const AuthenticationHandler(),
      ),
    );
  }
}
