// lib/features/home/widgets/animated_app_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:frontend_weft/features/profile/services/profile_api_service.dart';
import 'package:frontend_weft/features/profile/models/user_model.dart';
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
    return const SizedBox.shrink();
  }

  void _handleNotificationTap(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const NotificationsPage(),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}