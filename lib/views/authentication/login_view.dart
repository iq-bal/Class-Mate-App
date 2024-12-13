import 'package:classmate/controllers/authentication/auth_controller.dart';
import 'package:classmate/views/authentication/register_view.dart';
import 'package:classmate/views/authentication/widgets/custom_button.dart';
import 'package:classmate/views/authentication/widgets/custom_input_field.dart';
import 'package:classmate/views/authentication/widgets/custom_password_input.dart';
import 'package:classmate/views/authentication/widgets/info_section.dart';
import 'package:classmate/views/authentication/widgets/or_divider_with_tagline.dart';
import 'package:classmate/views/authentication/widgets/parent_container.dart';
import 'package:classmate/views/course_detail_screen_teacher/course_detail_screen.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  final String role;

  const LoginPage({super.key, required this.role});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthController _authController = AuthController();

  @override
  void initState() {
    super.initState();
    // Log the role when the widget is initialized
    debugPrint("Navigated to LoginPage with role: ${widget.role}");
  }

  void _login() async {
    const String email = "iqbal@gmail.com";
    const String password = "12345";
    await _authController.login(email, password);

    if (_authController.stateNotifier.value == AuthState.success && mounted) {
      if (widget.role.toLowerCase() == "teacher") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CourseDetailScreen()),
        );
      }
    } else {
      // If login failed, show an error message
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
    final TextEditingController _emailController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();

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
            "forgot your password?",
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
