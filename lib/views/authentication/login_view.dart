import 'package:classmate/controllers/authentication/auth_controller.dart';
import 'package:classmate/models/authentication/user_model.dart';
import 'package:classmate/views/authentication/register_view.dart';
import 'package:classmate/views/authentication/widgets/custom_button.dart';
import 'package:classmate/views/authentication/widgets/custom_input_field.dart';
import 'package:classmate/views/authentication/widgets/custom_password_input.dart';
import 'package:classmate/views/authentication/widgets/info_section.dart';
import 'package:classmate/views/authentication/widgets/or_divider_with_tagline.dart';
import 'package:classmate/views/authentication/widgets/parent_container.dart';
import 'package:classmate/views/course_detail_teacher/course_detail_teacher_view.dart';
import 'package:classmate/views/home/home_view.dart';
import 'package:flutter/material.dart';

import '../main_layout/main_layout.dart';

class LoginPage extends StatefulWidget {
  final String role;

  const LoginPage({super.key, required this.role});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthController _authController = AuthController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    debugPrint("Navigated to LoginPage with role: ${widget.role}");
  }

  void _login() async {
    // Fetch input values dynamically
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      // Show an error if fields are empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Perform login
    await _authController.login(email, password);
    if (_authController.stateNotifier.value == AuthState.success && mounted) {
      final UserModel user = _authController.user!;
      if (widget.role.toLowerCase() == "teacher" && user.role.toLowerCase() == "teacher") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CourseDetailScreen()),
        );
      } else if (widget.role.toLowerCase() == "student" && user.role.toLowerCase() == "student") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainLayout(role: "student")),
        );
      }
    } else {
      // Show error message if login failed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login failed. Please check your credentials.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ParentContainer(
      children: [
        const InfoSection(title: "Welcome Back", subtitle: "Enter your details below"),
        CustomInputField(label: "Email", controller: _emailController),
        CustomPasswordInput(controller: _passwordController),
        CustomButton(label: "Sign In", onPressed: _login),
        GestureDetector(
          onTap: () {
            // Handle forgot password action
          },
          child: const Text(
            "Forgot your password?",
            style: TextStyle(
              fontFamily: 'Raleway',
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
        const SizedBox(height: 20),
        OrDividerWithTagline(
          tagline: "Don't have an account?",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RegisterPage(role: widget.role), // Pass the role
              ),
            );
          },
        ),
      ],
    );
  }
}
