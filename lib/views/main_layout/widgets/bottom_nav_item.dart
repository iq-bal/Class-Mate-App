import 'package:flutter/material.dart';

class BottomNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;

  BottomNavItem({
    required this.icon, 
    this.activeIcon, 
    required this.label
  });
}