// lib/models/settings_item.dart
import 'package:flutter/material.dart';

class SettingsItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool hasArrow;

  SettingsItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.hasArrow = true,
  });
}