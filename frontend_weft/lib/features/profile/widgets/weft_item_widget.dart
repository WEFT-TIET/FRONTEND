// lib/widgets/weft_item_widget.dart
import 'package:flutter/material.dart';
import 'dart:ui';
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
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppPallete.glassWhite10,
            AppPallete.glassWhite05,
          ],
        ),
        border: Border.all(
          color: AppPallete.glassWhite20,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
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
                        color: AppPallete.profileTextSecondary,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      weft.time,
                      style: TextStyle(
                        color: AppPallete.profileTextSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Content
                Text(
                  weft.content,
                  style: TextStyle(
                    color: AppPallete.textPrimaryDark,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Interaction Buttons
                Row(
                  children: [
                    // Like Button
                    GestureDetector(
                      onTap: onLike,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppPallete.profileCardBackground,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.favorite,
                              color: AppPallete.red,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              weft.likes.toString(),
                              style: TextStyle(
                                color: AppPallete.textPrimaryDark,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Comment Button
                    GestureDetector(
                      onTap: onComment,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppPallete.profileCardBackground,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              color: AppPallete.textPrimaryDark,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              weft.comments.toString(),
                              style: TextStyle(
                                color: AppPallete.textPrimaryDark,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}