import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget{
  final String title;
  final VoidCallback? onBackPress;
  final VoidCallback? onMorePress;

  const CustomAppBar({
    super.key,
    required this.title,
    this.onBackPress,
    this.onMorePress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onBackPress ?? () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_ios, size: 18, color: Colors.black),
              ),
              const SizedBox(width: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: onMorePress,
            child: const Icon(Icons.more_vert, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
