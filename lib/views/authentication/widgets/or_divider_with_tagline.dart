import 'package:flutter/material.dart';

class OrDividerWithTagline extends StatelessWidget {
  final String tagline;
  final VoidCallback onTap;

  const OrDividerWithTagline({
    super.key,
    required this.tagline,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 50.0),
          child: Row(
            children: [
              Expanded(
                child: Divider(
                  color: Colors.grey,
                  thickness: 1,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  "or",
                  style: TextStyle(
                    fontFamily: 'Raleway',
                    color: Colors.grey,
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: Colors.grey,
                  thickness: 1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20), // Added SizedBox here
        GestureDetector(
          onTap: onTap,
          child: Text(
            tagline,
            style: const TextStyle(
              fontFamily: 'Raleway',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
