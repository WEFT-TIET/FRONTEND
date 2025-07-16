// lib/widgets/settings_menu_item.dart
import 'package:flutter/material.dart';
import 'package:frontend_weft/features/settings/models/settings_item.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';

class SettingsMenuItem extends StatelessWidget {
  final SettingsItem item;
  final bool isLast;

  const SettingsMenuItem({
    super.key,
    required this.item,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: !isLast
              ? const Border(
                  bottom: BorderSide(
                    color: AppPallete.glassWhite10,
                    width: 0.5,
                  ),
                )
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppPallete.profileCardBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                item.icon,
                size: 20,
                color: AppPallete.textPrimaryDark,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                item.title,
                style: const TextStyle(
                  color: AppPallete.textPrimaryDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (item.hasArrow)
              const Icon(
                Icons.chevron_right,
                color: AppPallete.profileTextSecondary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}