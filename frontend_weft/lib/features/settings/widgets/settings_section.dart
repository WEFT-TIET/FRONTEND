// lib/widgets/settings_section.dart
import 'package:flutter/material.dart';
import 'package:frontend_weft/features/settings/models/settings_item.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:frontend_weft/features/settings/widgets/settings_menu_item.dart';

class SettingsSection extends StatelessWidget {
  final String title;
  final List<SettingsItem> items;

  const SettingsSection({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              color: AppPallete.profileTextSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppPallete.cardColorDark,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: items.map((item) {
              final isLast = items.indexOf(item) == items.length - 1;
              return SettingsMenuItem(
                item: item,
                isLast: isLast,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}