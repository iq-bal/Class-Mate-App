import 'package:classmate/views/authentication/landing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:classmate/controllers/authentication/auth_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _handleLogout(BuildContext context, AuthController authController) async {
    try {
      await authController.logout(context);

      if (authController.stateNotifier.value == AuthState.success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LandingPage()),
        );
      } else if (authController.stateNotifier.value == AuthState.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authController.errorMessage ?? "Logout failed."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("An unexpected error occurred during logout."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () => _handleLogout(context, authController),
          icon: const Icon(Icons.logout, color: Colors.white),
          label: const Text(
            "Logout",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}
