// lib/pages/settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/features/settings/widgets/settings_menu_item.dart';
import 'package:frontend_weft/features/settings/models/settings_item.dart';
import 'package:frontend_weft/features/settings/widgets/settings_section.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:frontend_weft/features/auth/viewmodel/auth_viewmodel.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppPallete.gradient1,
            AppPallete.gradient2,
            AppPallete.gradient3,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: AppPallete.transperantColor,
        appBar: AppBar(
          title: const Text(
            'Settings',
            style: TextStyle(
              color: AppPallete.textPrimaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppPallete.transperantColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppPallete.textPrimaryDark),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Account Section
                  SettingsSection(
                    title: 'Account',
                    items: [
                      SettingsItem(
                        icon: Icons.visibility_off_outlined,
                        title: 'Your Activity',
                        onTap: () => _navigateToActivity(context),
                      ),
                      SettingsItem(
                        icon: Icons.visibility_off,
                        title: 'Hide Yourself',
                        onTap: () => _toggleHideProfile(context),
                      ),
                      SettingsItem(
                        icon: Icons.lock_outline,
                        title: 'Change Password',
                        onTap: () => _navigateToChangePassword(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Privacy & Safety Section
                  SettingsSection(
                    title: 'Privacy & Safety',
                    items: [
                      SettingsItem(
                        icon: Icons.block_outlined,
                        title: 'Block List',
                        onTap: () => _navigateToBlockList(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Support Section
                  SettingsSection(
                    title: 'Support',
                    items: [
                      SettingsItem(
                        icon: Icons.bug_report_outlined,
                        title: 'Report Bug',
                        onTap: () => _navigateToReportBug(context),
                      ),
                      SettingsItem(
                        icon: Icons.help_outline,
                        title: 'Help Center',
                        onTap: () => _navigateToHelpCenter(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 100), // Space for logout button
                ],
              ),
            ),
            
            // Logout Button at Bottom
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () => _showLogoutDialog(context,ref),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  // Navigation Methods
  void _navigateToActivity(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const YourActivityPage()),
    );
  }

  void _navigateToChangePassword(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChangePasswordPage()),
    );
  }

  void _navigateToBlockList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BlockListPage()),
    );
  }

  void _navigateToReportBug(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ReportBugPage()),
    );
  }

  void _navigateToHelpCenter(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HelpCenterPage()),
    );
  }

  void _toggleHideProfile(BuildContext context) {
    // Implement hide profile toggle logic
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hide Profile'),
        content: const Text('Do you want to hide your profile from other users?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement hide profile logic
            },
            child: const Text('Hide'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
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
              // Use your existing logout logic
              await ref.read(authViewModelProvider.notifier).logoutUser();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _performLogout(BuildContext context) {
    // This method is no longer needed since we're using the Riverpod logic
  }
}

// Example placeholder pages - you can implement these as needed
class YourActivityPage extends StatelessWidget {
  const YourActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Activity'),
        backgroundColor: AppPallete.transperantColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppPallete.textPrimaryDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: AppPallete.transperantColor,
      body: const Center(
        child: Text(
          'Your Activity Page',
          style: TextStyle(color: AppPallete.textPrimaryDark),
        ),
      ),
    );
  }
}

class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
        backgroundColor: AppPallete.transperantColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppPallete.textPrimaryDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: AppPallete.transperantColor,
      body: const Center(
        child: Text(
          'Change Password Page',
          style: TextStyle(color: AppPallete.textPrimaryDark),
        ),
      ),
    );
  }
}

class BlockListPage extends StatelessWidget {
  const BlockListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Block List'),
        backgroundColor: AppPallete.transperantColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppPallete.textPrimaryDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: AppPallete.transperantColor,
      body: const Center(
        child: Text(
          'Block List Page',
          style: TextStyle(color: AppPallete.textPrimaryDark),
        ),
      ),
    );
  }
}

class ReportBugPage extends StatelessWidget {
  const ReportBugPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Bug'),
        backgroundColor: AppPallete.transperantColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppPallete.textPrimaryDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: AppPallete.transperantColor,
      body: const Center(
        child: Text(
          'Report Bug Page',
          style: TextStyle(color: AppPallete.textPrimaryDark),
        ),
      ),
    );
  }
}

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help Center'),
        backgroundColor: AppPallete.transperantColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppPallete.textPrimaryDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: AppPallete.transperantColor,
      body: const Center(
        child: Text(
          'Help Center Page',
          style: TextStyle(color: AppPallete.textPrimaryDark),
        ),
      ),
    );
  }
}