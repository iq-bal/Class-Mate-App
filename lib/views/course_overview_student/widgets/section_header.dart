import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String leftTitle;
  final String rightTitle;
  final TextStyle? leftTextStyle;
  final TextStyle? rightTextStyle;
  final bool isLeftSelected;
  final VoidCallback onLeftTap;
  final VoidCallback onRightTap;

  const SectionHeader({
    required this.leftTitle,
    required this.rightTitle,
    this.leftTextStyle,
    this.rightTextStyle,
    this.isLeftSelected = true,
    required this.onLeftTap,
    required this.onRightTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onLeftTap,
              child: Column(
                children: [
                  Text(
                    leftTitle,
                    style: isLeftSelected
                        ? (leftTextStyle ??
                            const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ))
                        : TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                  ),
                  const SizedBox(height: 4),
                  Divider(
                    color: isLeftSelected ? Colors.green : Colors.transparent,
                    thickness: 2,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: onRightTap,
              child: Column(
                children: [
                  Text(
                    rightTitle,
                    style: !isLeftSelected
                        ? (rightTextStyle ??
                            const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ))
                        : TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                  ),
                  const SizedBox(height: 4),
                  Divider(
                    color: !isLeftSelected ? Colors.green : Colors.transparent,
                    thickness: 2,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
