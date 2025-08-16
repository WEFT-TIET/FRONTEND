// lib/features/notifications/pages/notifications_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:frontend_weft/features/notifications/models/notification_model.dart';
import 'package:frontend_weft/features/notifications/viewmodel/notification_viewmodel.dart';
import 'package:frontend_weft/features/notifications/widgets/notification_tile.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    // Fetch notifications when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotifications();
    });
  }

  Future<void> _loadNotifications() async {
    await ref.read(notificationViewModelProvider.notifier).fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final notificationState = ref.watch(notificationViewModelProvider);
    final groupedNotifications = ref.read(notificationViewModelProvider.notifier).getGroupedNotifications();

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
        appBar: _buildAppBar(),
        body: _buildBody(notificationState, groupedNotifications),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Notifications',
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
    );
  }

  Widget _buildBody(NotificationState state, Map<String, List<NotificationModel>> groupedNotifications) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppPallete.gradient1,
        ),
      );
    }

    if (state.error != null) {
      return _buildErrorState();
    }

    if (state.notifications.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      color: AppPallete.gradient1,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 20),
        itemCount: groupedNotifications.length,
        itemBuilder: (context, index) {
          final groupKey = groupedNotifications.keys.elementAt(index);
          final notifications = groupedNotifications[groupKey]!;
          
          return _buildNotificationGroup(groupKey, notifications);
        },
      ),
    );
  }

  Widget _buildNotificationGroup(String groupKey, List<NotificationModel> notifications) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Group header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            groupKey,
            style: GoogleFonts.getFont(
              'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppPallete.textPrimaryDark,
            ),
          ),
        ),
        
        // Notifications in this group
        ...notifications.map((notification) => NotificationTile(
          notification: notification,
          onTap: () => _handleNotificationTap(notification),
        )),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppPallete.greyColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: GoogleFonts.getFont(
              'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppPallete.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Unable to load notifications',
            style: GoogleFonts.getFont(
              'Inter',
              fontSize: 14,
              color: AppPallete.textSecondaryDark,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadNotifications,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPallete.gradient1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Try Again',
              style: GoogleFonts.getFont(
                'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppPallete.whiteColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppPallete.gradient1.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none,
              size: 40,
              color: AppPallete.gradient1,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No notifications yet',
            style: GoogleFonts.getFont(
              'Inter',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppPallete.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'When you get notifications, they\'ll appear here',
            style: GoogleFonts.getFont(
              'Inter',
              fontSize: 14,
              color: AppPallete.textSecondaryDark,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(NotificationModel notification) {
    // Handle different notification types
    switch (notification.type) {
      case NotificationType.like:
      case NotificationType.comment:
        // Navigate to the post
        if (notification.postId != null) {
          // Navigate to post detail page
          print('Navigate to post: ${notification.postId}');
        }
        break;
      case NotificationType.follow:
        // Navigate to user profile
        if (notification.userId.isNotEmpty) {
          // Navigate to user profile
          print('Navigate to user profile: ${notification.userId}');
        }
        break;
      case NotificationType.mention:
        // Navigate to the post where mentioned
        if (notification.postId != null) {
          // Navigate to post detail page
          print('Navigate to mentioned post: ${notification.postId}');
        }
        break;
      case NotificationType.post:
        // Navigate to the new post
        if (notification.postId != null) {
          // Navigate to post detail page
          print('Navigate to new post: ${notification.postId}');
        }
        break;
      case NotificationType.system:
        // Show system notification details
        _showSystemNotificationDialog(notification);
        break;
    }
  }

  void _showSystemNotificationDialog(NotificationModel notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppPallete.scaffoldBackgroundColorDark,
        title: Text(
          'System Notification',
          style: GoogleFonts.getFont(
            'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppPallete.textPrimaryDark,
          ),
        ),
        content: Text(
          notification.message,
          style: GoogleFonts.getFont(
            'Inter',
            fontSize: 14,
            color: AppPallete.textSecondaryDark,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: GoogleFonts.getFont(
                'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppPallete.gradient1,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 