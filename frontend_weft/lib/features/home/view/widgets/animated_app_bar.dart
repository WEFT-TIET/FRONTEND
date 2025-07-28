// lib/features/home/widgets/animated_app_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:frontend_weft/features/post/viewmodel/post_viewmodel.dart';
import 'package:frontend_weft/features/profile/services/profile_api_service.dart';
import 'package:frontend_weft/features/profile/models/user_model.dart';
import 'package:frontend_weft/features/notifications/viewmodel/notification_viewmodel.dart';
import 'package:frontend_weft/features/notifications/pages/notifications_page.dart';
import 'package:google_fonts/google_fonts.dart';

// Provider to get user profile data
final userProfileProvider = FutureProvider<UserModel?>((ref) async {
  final api = ref.read(profileApiServiceProvider);
  return await api.getUserProfile();
});

class AnimatedAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final Animation<double> animation;

  const AnimatedAppBar({
    super.key,
    required this.animation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RepaintBoundary(
      child: AppBar(
        backgroundColor: AppPallete.transperantColor,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        title: _buildAnimatedTitle(ref),
        iconTheme: const IconThemeData(color: AppPallete.textPrimaryDark),
        actions: [
          _buildRefreshButton(context, ref),
          _buildNotificationButton(context),
        ],
      ),
    );
  }

  Widget _buildAnimatedTitle(WidgetRef ref) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 20 * (1 - animation.value)),
            child: Opacity(
              opacity: animation.value,
              child: Consumer(
                builder: (context, ref, child) {
                  final userProfileAsync = ref.watch(userProfileProvider);
                  
                  return userProfileAsync.when(
                    data: (user) {
                      if (user == null) {
                        return Text(
                          'Hi there!',
                          style: GoogleFonts.getFont(
                            'Indie Flower',
                            fontSize: 30,
                            color: AppPallete.textPrimaryDark,
                          ),
                        );
                      }
                      
                      // Extract first name from full name
                      final firstName = _getFirstName(user.name);
                      
                      return Text(
                        'Hi $firstName!',
                        style: GoogleFonts.getFont(
                          'Indie Flower',
                          fontSize: 30,
                          color: AppPallete.textPrimaryDark,
                        ),
                      );
                    },
                    loading: () => Text(
                      'Hi there!',
                      style: GoogleFonts.getFont(
                        'Indie Flower',
                        fontSize: 30,
                        color: AppPallete.textPrimaryDark,
                      ),
                    ),
                    error: (error, stack) => Text(
                      'Hi there!',
                      style: GoogleFonts.getFont(
                        'Indie Flower',
                        fontSize: 30,
                        color: AppPallete.textPrimaryDark,
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
  // Helper method to extract first name from full name
  String _getFirstName(String fullName) {
    if (fullName.isEmpty) return 'there';
    
    // Split by space and take the first part
    final nameParts = fullName.trim().split(' ');
    return nameParts.isNotEmpty ? nameParts.first : 'there';
  }

  Widget _buildRefreshButton(BuildContext context, WidgetRef ref) {
    return RepaintBoundary(
      child: IconButton(
        icon: const Icon(Icons.refresh),
        onPressed: () => _handleRefresh(context, ref),
        tooltip: 'Refresh posts',
      ),
    );
  }

  Widget _buildNotificationButton(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        children: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => _handleNotificationTap(context),
            tooltip: 'Notifications',
          ),
          _buildNotificationBadge(),
        ],
      ),
    );
  }

  Widget _buildNotificationBadge() {
    return Consumer(
      builder: (context, ref, child) {
        final unreadCount = ref.watch(unreadNotificationCountProvider);
        
        if (unreadCount == 0) {
          return const SizedBox.shrink();
        }
        
        return Positioned(
          right: 11,
          top: 11,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: AppPallete.gradient1,
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: AppPallete.gradient1.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            constraints: const BoxConstraints(
              minWidth: 14,
              minHeight: 14,
            ),
            child: Text(
              unreadCount > 99 ? '99+' : unreadCount.toString(),
              style: const TextStyle(
                color: AppPallete.whiteColor,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }

  void _handleRefresh(BuildContext context, WidgetRef ref) {
    try {
      ref.read(postViewModelProvider.notifier).refreshPosts();
      _showSnackBar(
        context, 
        'Refreshing posts...', 
        const Color.fromRGBO(74, 78, 138, 1),
        duration: const Duration(seconds: 1),
      );
    } catch (e) {
      _showSnackBar(
        context, 
        'Failed to refresh posts', 
        AppPallete.red,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void _handleNotificationTap(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const NotificationsPage(),
      ),
    );
  }

  void _showSnackBar(
    BuildContext context, 
    String message, 
    Color color, {
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}