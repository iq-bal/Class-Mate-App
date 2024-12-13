import 'package:flutter/material.dart';

class CustomPasswordInput extends StatefulWidget {
  final TextEditingController controller;

  const CustomPasswordInput({
    super.key,
    required this.controller,
  });

  @override
  _CustomPasswordInputState createState() => _CustomPasswordInputState();
}

class _CustomPasswordInputState extends State<CustomPasswordInput> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        children: [
          TextField(
            controller: widget.controller, // Access controller from widget
            obscureText: !_isPasswordVisible, // Toggle visibility
            decoration: InputDecoration(
              labelText: "Password",
              labelStyle: const TextStyle(
                fontFamily: 'Raleway',
                fontSize: 16,
                color: Colors.brown,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
