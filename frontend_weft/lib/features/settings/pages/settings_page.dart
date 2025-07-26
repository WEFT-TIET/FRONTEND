// lib/pages/settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/features/settings/subpages/change_password.dart';
import 'package:frontend_weft/features/settings/subpages/help_center.dart';
import 'package:frontend_weft/features/settings/models/settings_item.dart';
import 'package:frontend_weft/features/settings/widgets/settings_section.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:frontend_weft/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:frontend_weft/features/settings/subpages/about_us.dart';
import 'package:frontend_weft/features/settings/viewmodels/block_list_viewmodel.dart';
import 'package:frontend_weft/features/settings/widgets/blocked_user_card.dart';
import 'package:frontend_weft/features/post/viewmodel/post_viewmodel.dart';

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
                        icon: Icons.help_outline,
                        title: 'Help Center',
                        onTap: () => _navigateToHelpCenter(context),
                      ),
                      SettingsItem(
                        icon: Icons.people_outline,
                        title: 'About Us',
                        onTap: () => _navigateToAboutUs(context),
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

  /*void _navigateToReportBug(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ReportBugPage(userEmail: '',)),
    );
  }*/

  void _navigateToHelpCenter(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HelpCenterPage()),
    );
  } 
  void _navigateToAboutUs(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AboutUsPage()),
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
              // Call the logout method from the auth view model
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

class BlockListPage extends ConsumerWidget {
  const BlockListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blockedUsersAsync = ref.watch(blockedUsersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Block List'),
        backgroundColor: AppPallete.transperantColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppPallete.textPrimaryDark),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppPallete.textPrimaryDark),
            onPressed: () {
              ref.read(blockListViewModelProvider.notifier).refreshBlockedUsers(ref);
            },
          ),
        ],
      ),
      backgroundColor: AppPallete.transperantColor,
      body: blockedUsersAsync.when(
        data: (blockedUsers) {
          if (blockedUsers.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.block_outlined,
                    size: 64,
                    color: AppPallete.textPrimaryDark,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No blocked users',
                    style: TextStyle(
                      color: AppPallete.textPrimaryDark,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Users you block will appear here',
                    style: TextStyle(
                      color: AppPallete.whiteColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(blockListViewModelProvider.notifier).refreshBlockedUsers(ref);
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: blockedUsers.length,
              itemBuilder: (context, index) {
                return BlockedUserCard(blockedUser: blockedUsers[index]);
              },
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppPallete.textPrimaryDark),
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppPallete.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading block list',
                style: const TextStyle(
                  color: AppPallete.textPrimaryDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: const TextStyle(
                  color: AppPallete.whiteColor,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(blockListViewModelProvider.notifier).refreshBlockedUsers(ref);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}