import 'package:classmate/controllers/authentication/auth_controller.dart';
import 'package:classmate/views/authentication/login_view.dart';
import 'package:classmate/views/authentication/widgets/custom_button.dart';
import 'package:classmate/views/authentication/widgets/custom_input_field.dart';
import 'package:classmate/views/authentication/widgets/custom_password_input.dart';
import 'package:classmate/views/authentication/widgets/info_section.dart';
import 'package:classmate/views/authentication/widgets/or_divider_with_tagline.dart';
import 'package:classmate/views/authentication/widgets/parent_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  final String role;

  const RegisterPage({super.key, required this.role});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _register(AuthController authController) async {
    final String email = _emailController.text.trim();
    final String name = _nameController.text.trim();
    final String password = _passwordController.text.trim();
    final String role = widget.role.toLowerCase();

    if (email.isEmpty || name.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await authController.register(email, name, password, role);

    if (authController.stateNotifier.value == AuthState.success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful! Please login.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage(role: widget.role)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authController.errorMessage ?? 'Registration failed.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);

    return ParentContainer(
      children: [
        const InfoSection(title: "Get Started", subtitle: "Never miss anything"),
        CustomInputField(label: "Email", controller: _emailController),
        CustomInputField(label: "Name", controller: _nameController),
        CustomPasswordInput(controller: _passwordController),
        ValueListenableBuilder<AuthState>(
          valueListenable: authController.stateNotifier,
          builder: (context, state, _) {
            if (state == AuthState.loading) {
              return const CircularProgressIndicator();
            }

            return CustomButton(
              label: "Register",
              onPressed: () => _register(authController),
            );
          },
        ),
      ],
    );
  }
}
