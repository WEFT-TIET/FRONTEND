// lib/features/home/widgets/animated_app_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:frontend_weft/features/post/viewmodel/post_viewmodel.dart';
import 'package:google_fonts/google_fonts.dart';

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
        title: _buildAnimatedTitle(),
        iconTheme: const IconThemeData(color: AppPallete.textPrimaryDark),
        actions: [
          _buildRefreshButton(context, ref),
          _buildNotificationButton(context),
        ],
      ),
    );
  }

  Widget _buildAnimatedTitle() {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 20 * (1 - animation.value)),
            child: Opacity(
              opacity: animation.value,
              child: Text(
                'Hi Rudra !',
                style: GoogleFonts.getFont(
                  'Indie Flower',
                  fontSize: 30,
                  color: AppPallete.textPrimaryDark,
                ),
              ),
            ),
          );
        },
      ),
    );
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
        child: const Text(
          '3',
          style: TextStyle(
            color: AppPallete.whiteColor,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _handleRefresh(BuildContext context, WidgetRef ref) {
    try {
      ref.read(postViewModelProvider.notifier).refreshPosts();
      _showSnackBar(
        context, 
        'Refreshing posts...', 
        AppPallete.gradient2,
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
    _showSnackBar(
      context, 
      'No new notifications', 
      AppPallete.greyColor,
      duration: const Duration(seconds: 2),
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