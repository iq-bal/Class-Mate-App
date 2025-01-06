import 'package:classmate/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import 'token_storage.dart';
import 'package:classmate/views/home_teacher/home_teacher_view.dart';
import 'package:classmate/views/home/home_view.dart';
import 'package:classmate/views/authentication/landing.dart';

class AuthenticationHandler extends StatefulWidget {
  const AuthenticationHandler({super.key});

  @override
  State<AuthenticationHandler> createState() => _AuthenticationHandlerState();
}

class _AuthenticationHandlerState extends State<AuthenticationHandler> {
  final TokenStorage _tokenStorage = TokenStorage();

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    try {
      // Retrieve the access token
      String? accessToken = await _tokenStorage.retrieveAccessToken();

      if (accessToken == null || JwtDecoder.isExpired(accessToken)) {
        // No valid token or token expired
        Provider.of<AuthProvider>(context, listen: false)
            .setAuthentication(false, null);
        return;
      }

      // Decode the token to extract user role
      Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);
      String role = decodedToken['role'] ?? 'user';

      Provider.of<AuthProvider>(context, listen: false)
          .setAuthentication(true, role);
    } catch (e) {
      // Handle errors (e.g., token retrieval issues)
      print("Error during authentication check: $e");
      Provider.of<AuthProvider>(context, listen: false)
          .setAuthentication(false, null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (!authProvider.isLoggedIn) {
      return const LandingPage();
    }

    switch (authProvider.role?.toLowerCase()) {
      case 'teacher':
        return const HomeTeacherView();
      case 'student':
        return const HomeView();
      default:
        return const LandingPage();
    }
  }
}
