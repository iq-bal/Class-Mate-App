import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String leftTitle;
  final String rightTitle;
  final TextStyle? leftTextStyle;
  final TextStyle? rightTextStyle;

  const SectionHeader({
    required this.leftTitle,
    required this.rightTitle,
    this.leftTextStyle,
    this.rightTextStyle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  leftTitle,
                  style: leftTextStyle ??
                      const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                const Divider(color: Colors.green, thickness: 2),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  rightTitle,
                  style: rightTextStyle ??
                      const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
