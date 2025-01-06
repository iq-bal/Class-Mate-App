import 'package:classmate/core/authentication_handler.dart';
import 'package:classmate/providers/auth_provider.dart';
import 'package:classmate/views/authentication/landing.dart';
import 'package:classmate/views/authentication/login_view.dart';
import 'package:classmate/views/main_layout/main_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:classmate/core/helper_function.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeNotifications();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
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
