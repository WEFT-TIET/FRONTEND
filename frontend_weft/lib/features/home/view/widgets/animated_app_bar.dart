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
    return AppBar(
      backgroundColor: AppPallete.transperantColor,
      elevation: 0,
      title: AnimatedBuilder(
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
      iconTheme: IconThemeData(color: AppPallete.textPrimaryDark),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            ref.read(postViewModelProvider.notifier).refreshPosts();
            _showSnackBar(context, 'Refreshing posts...', Colors.blue);
          },
        ),
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                _showSnackBar(context, 'No new notifications', Colors.grey);
              },
            ),
            Positioned(
              right: 11,
              top: 11,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: AppPallete.gradient1,
                  borderRadius: BorderRadius.circular(6),
                ),
                constraints: const BoxConstraints(
                  minWidth: 14,
                  minHeight: 14,
                ),
                child: Text(
                  '3',
                  style: TextStyle(
                    color: AppPallete.whiteColor,
                    fontSize: 8,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}