// lib/features/notifications/widgets/notification_tile.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import 'package:frontend_weft/features/notifications/models/notification_model.dart';
import 'package:frontend_weft/features/notifications/viewmodel/notification_viewmodel.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationTile extends ConsumerWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RepaintBoundary(
      child: InkWell(
        onTap: () {
          onTap?.call();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: notification.isRead 
                ? Colors.transparent 
                : AppPallete.gradient1.withOpacity(0.1),
            border: Border(
              bottom: BorderSide(
                color: AppPallete.greyColor.withOpacity(0.2),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture
              _buildProfilePicture(),
              
              const SizedBox(width: 12),
              
              // Notification Content
              Expanded(
                child: _buildNotificationContent(),
              ),
              
              const SizedBox(width: 12),
              
              // Action Button or Post Image
              _buildActionSection(ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePicture() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppPallete.gradient1.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ClipOval(
        child: notification.user?.image_url != null
            ? Image.asset(
                notification.user!.image_url!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildDefaultAvatar();
                },
              )
            : _buildDefaultAvatar(),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppPallete.gradient1,
            AppPallete.gradient2,
          ],
        ),
      ),
      child: Icon(
        Icons.person,
        color: AppPallete.whiteColor,
        size: 24,
      ),
    );
  }

  Widget _buildNotificationContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Username and action
        RichText(
          text: TextSpan(
            style: GoogleFonts.getFont(
              'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppPallete.textPrimaryDark,
            ),
            children: [
              TextSpan(text: notification.user?.name ?? 'Unknown User'),
              TextSpan(
                text: ' ${notification.displayMessage}',
                style: GoogleFonts.getFont(
                  'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppPallete.textSecondaryDark,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 4),
        
        // Time ago
        Text(
          notification.timeAgo,
          style: GoogleFonts.getFont(
            'Inter',
            fontSize: 12,
            color: AppPallete.textSecondaryDark,
          ),
        ),
        
        // Comment text (if available)
        if (notification.commentText != null) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppPallete.scaffoldBackgroundColorDark.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              notification.commentText!,
              style: GoogleFonts.getFont(
                'Inter',
                fontSize: 13,
                color: AppPallete.textPrimaryDark,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionSection(WidgetRef ref) {
    // For post-related notifications, show post image
    if (notification.postImage != null) {
      return _buildPostImage();
    }
    
    // For all notifications, show action icon
    return _buildActionIcon();
  }

  Widget _buildPostImage() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: AppPallete.greyColor.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.asset(
          notification.postImage!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppPallete.greyColor.withOpacity(0.2),
              child: Icon(
                Icons.image,
                color: AppPallete.greyColor,
                size: 20,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionIcon() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: notification.actionColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Icon(
        notification.actionIcon,
        color: notification.actionColor,
        size: 20,
      ),
    );
  }
} 