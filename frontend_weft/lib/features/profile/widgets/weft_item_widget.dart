// lib/widgets/weft_item_widget.dart
import 'package:flutter/material.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:frontend_weft/features/profile/models/weft_model.dart';

class WeftItemWidget extends StatelessWidget {
  final WeftModel weft;
  final VoidCallback? onLike;
  final VoidCallback? onComment;

  const WeftItemWidget({
    Key? key,
    required this.weft,
    this.onLike,
    this.onComment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF3A3D5F).withOpacity(0.6), // Solid color, no glass effect
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date and Time Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    weft.date,
                    style: TextStyle(
                      color: AppPallete.profileTextSecondary.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    weft.time,
                    style: TextStyle(
                      color: AppPallete.profileTextSecondary.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Content
              Text(
                weft.content,
                style: const TextStyle(
                  color: AppPallete.textPrimaryDark,
                  fontSize: 18,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              
              // Interaction Buttons
              Row(
                children: [
                  // Like Button
                  _buildInteractionButton(
                    icon: Icons.favorite,
                    count: weft.likes.toString(),
                    iconColor: AppPallete.red,
                    onTap: onLike,
                  ),
                  const SizedBox(width: 12),
                  
                  // Comment Button
                  _buildInteractionButton(
                    icon: Icons.chat_bubble_outline,
                    count: weft.comments.toString(),
                    iconColor: AppPallete.textPrimaryDark,
                    onTap: onComment,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInteractionButton({
    required IconData icon,
    required String count,
    required Color iconColor,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: AppPallete.profileCardBackground.withOpacity(0.8),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                count,
                style: const TextStyle(
                  color: AppPallete.textPrimaryDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}