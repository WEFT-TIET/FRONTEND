// lib/features/notifications/pages/notification_settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationSettingsPage extends ConsumerStatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  ConsumerState<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends ConsumerState<NotificationSettingsPage> {
  bool _likesEnabled = true;
  bool _commentsEnabled = true;
  bool _followsEnabled = true;
  bool _mentionsEnabled = true;
  bool _postsEnabled = true;
  bool _systemEnabled = true;
  bool _pushNotifications = true;
  bool _emailNotifications = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
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
          title: Text(
            'Notification Settings',
            style: GoogleFonts.getFont(
              'Inter',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppPallete.textPrimaryDark,
            ),
          ),
          backgroundColor: AppPallete.transperantColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppPallete.textPrimaryDark),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionHeader('Push Notifications'),
            _buildSwitchTile(
              'Push Notifications',
              'Receive notifications on your device',
              _pushNotifications,
              (value) => setState(() => _pushNotifications = value),
              icon: Icons.notifications,
            ),
            _buildSwitchTile(
              'Email Notifications',
              'Receive notifications via email',
              _emailNotifications,
              (value) => setState(() => _emailNotifications = value),
              icon: Icons.email,
            ),
            
            const SizedBox(height: 24),
            
            _buildSectionHeader('Notification Types'),
            _buildSwitchTile(
              'Likes',
              'When someone likes your posts',
              _likesEnabled,
              (value) => setState(() => _likesEnabled = value),
              icon: Icons.favorite,
              iconColor: Colors.red,
            ),
            _buildSwitchTile(
              'Comments',
              'When someone comments on your posts',
              _commentsEnabled,
              (value) => setState(() => _commentsEnabled = value),
              icon: Icons.comment,
              iconColor: Colors.blue,
            ),
            _buildSwitchTile(
              'Follows',
              'When someone follows you',
              _followsEnabled,
              (value) => setState(() => _followsEnabled = value),
              icon: Icons.person_add,
              iconColor: Colors.green,
            ),
            _buildSwitchTile(
              'Mentions',
              'When someone mentions you',
              _mentionsEnabled,
              (value) => setState(() => _mentionsEnabled = value),
              icon: Icons.alternate_email,
              iconColor: Colors.orange,
            ),
            _buildSwitchTile(
              'New Posts',
              'When people you follow post',
              _postsEnabled,
              (value) => setState(() => _postsEnabled = value),
              icon: Icons.post_add,
              iconColor: Colors.purple,
            ),
            _buildSwitchTile(
              'System',
              'Important updates and announcements',
              _systemEnabled,
              (value) => setState(() => _systemEnabled = value),
              icon: Icons.info,
              iconColor: Colors.grey,
            ),
            
            const SizedBox(height: 32),
            
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: GoogleFonts.getFont(
          'Inter',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppPallete.textPrimaryDark,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged, {
    IconData? icon,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppPallete.scaffoldBackgroundColorDark.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppPallete.greyColor.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: icon != null
            ? Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (iconColor ?? AppPallete.gradient1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? AppPallete.gradient1,
                  size: 20,
                ),
              )
            : null,
        title: Text(
          title,
          style: GoogleFonts.getFont(
            'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppPallete.textPrimaryDark,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.getFont(
            'Inter',
            fontSize: 14,
            color: AppPallete.textSecondaryDark,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppPallete.gradient1,
          activeTrackColor: AppPallete.gradient1.withOpacity(0.3),
          inactiveThumbColor: AppPallete.greyColor,
          inactiveTrackColor: AppPallete.greyColor.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppPallete.gradient1,
            AppPallete.gradient2,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppPallete.gradient1.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _saveSettings,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Text(
              'Save Settings',
              style: GoogleFonts.getFont(
                'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppPallete.whiteColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _saveSettings() {
    // Here you would typically save the settings to backend/local storage
    print('Saving notification settings...');
    print('Push Notifications: $_pushNotifications');
    print('Email Notifications: $_emailNotifications');
    print('Likes: $_likesEnabled');
    print('Comments: $_commentsEnabled');
    print('Follows: $_followsEnabled');
    print('Mentions: $_mentionsEnabled');
    print('Posts: $_postsEnabled');
    print('System: $_systemEnabled');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Notification settings saved',
          style: GoogleFonts.getFont(
            'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: AppPallete.gradient1,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );

    Navigator.of(context).pop();
  }
} 