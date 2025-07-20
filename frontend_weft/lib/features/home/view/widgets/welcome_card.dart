// lib/features/home/widgets/welcome_card.dart
import 'package:flutter/material.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeCard extends StatelessWidget {
  final Animation<double> animation;
  
  const WelcomeCard({
    super.key,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - animation.value)),
          child: Opacity(
            opacity: animation.value,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppPallete.whiteColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppPallete.whiteColor.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _buildIconContainer(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextContent(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIconContainer() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppPallete.gradient1.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.people,
        color: AppPallete.whiteColor,
        size: 24,
      ),
    );
  }

  Widget _buildTextContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Connect, learn, and grow together! 🌱",
          style: GoogleFonts.getFont(
            'Oswald',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppPallete.textPrimaryDark,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Welcome back to your learning community',
          style: GoogleFonts.getFont(
            'Indie Flower',
            fontSize: 10,
            color: AppPallete.textPrimaryDark.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}