import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:frontend_weft/features/auth/viewmodel/auth_viewmodel.dart';

void showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppPallete.cardColorDark,
        title: const Text(
          'Logout',
          style: TextStyle(color: AppPallete.textPrimaryDark),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: AppPallete.textPrimaryDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppPallete.textPrimaryDark),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // Call the logout method from the auth view model
              await ref.read(authViewModelProvider.notifier).logoutUser();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/welcome',
                (route) => false,
              );
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }