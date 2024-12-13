import 'package:classmate/controllers/authentication/auth_controller.dart';
import 'package:classmate/views/authentication/login_view.dart';
import 'package:classmate/views/authentication/widgets/custom_button.dart';
import 'package:classmate/views/authentication/widgets/custom_input_field.dart';
import 'package:classmate/views/authentication/widgets/custom_password_input.dart';
import 'package:classmate/views/authentication/widgets/info_section.dart';
import 'package:classmate/views/authentication/widgets/or_divider_with_tagline.dart';
import 'package:classmate/views/authentication/widgets/parent_container.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  final String role;

  const RegisterPage({super.key,required this.role});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  @override
  void initState() {
    super.initState();
    // Log the role when the widget is initialized
    debugPrint("Navigated to RegisterPage with role: ${widget.role}");
  }

  final AuthController _authController = AuthController();
  void _register(){
    const String email = "iqbal10000300@gmail.com";
    const String name = "iqbal";
    const String password = "12345";
    const String role = 'teacher';
    _authController.register(email,name, password,role);
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController _emailController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();
    final TextEditingController _nameController = TextEditingController();

    return ParentContainer(children: [
      const InfoSection(title: "Get Started", subtitle: "Never miss anything"),
      CustomInputField(label: "Email", controller: _emailController),
      CustomInputField(label: "Name", controller: _nameController),
      CustomPasswordInput(controller: _passwordController),
      CustomButton(label: "Register", onPressed: _register),
      OrDividerWithTagline(
        tagline: "Already have an account?",
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoginPage(role: widget.role), // Pass the role
            ),
          );
        },
      ),
    ]);
  }
}
