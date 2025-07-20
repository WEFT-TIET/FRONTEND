// lib/widgets/profile_dialogs.dart
import 'package:flutter/material.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';

class ProfileDialogs {
  static void showImagePicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppPallete.profileDialogBackground,
        title: Text(
          'Change Profile Picture',
          style: TextStyle(color: AppPallete.textPrimaryDark),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: AppPallete.textPrimaryDark),
              title: Text('Camera', style: TextStyle(color: AppPallete.textPrimaryDark)),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement camera functionality
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: AppPallete.textPrimaryDark),
              title: Text('Gallery', style: TextStyle(color: AppPallete.textPrimaryDark)),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement gallery functionality
              },
            ),
          ],
        ),
      ),
    );
  }

  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppPallete.profileCardBackground,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}