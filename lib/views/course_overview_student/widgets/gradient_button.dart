import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback? onPressed;

  const GradientButton({
    required this.buttonText,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30), // Smooth rounded corners
          gradient: isDisabled
              ? const LinearGradient(
                  colors: [Colors.grey, Colors.grey], // Grey gradient when disabled
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [Color(0xFF56ab2f), Color(0xFFA8E063)], // Green gradient
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          boxShadow: [
            BoxShadow(
              color: isDisabled
                  ? Colors.grey.withOpacity(0.3)
                  : Colors.green.withOpacity(0.3), // Subtle shadow
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent, // Transparent for gradient
            shadowColor: Colors.transparent, // Remove default shadow
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            minimumSize: const Size(double.infinity, 50), // Full-width button
          ),
          child: Text(
            buttonText,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDisabled ? Colors.white.withOpacity(0.7) : Colors.white, // Contrast with the gradient
              letterSpacing: 1.2, // Subtle letter spacing
            ),
          ),
        ),
      ),
    );
  }
}
