import 'package:flutter/material.dart';

class HomeTeacherView extends StatelessWidget {
  const HomeTeacherView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Screen'),
      ),
      body: const Center(
        child: Text(
          'Welcome to the Teacher Screen!',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
