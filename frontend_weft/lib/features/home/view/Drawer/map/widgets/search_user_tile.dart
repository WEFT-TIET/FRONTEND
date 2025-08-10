import 'package:flutter/material.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import '../models/trusted_user_model.dart';

class SearchUserTile extends StatelessWidget {
  final TrustedUserModel user;
  final bool isAlreadyTrusted;
  final VoidCallback onAdd;

  const SearchUserTile({
    super.key,
    required this.user,
    required this.isAlreadyTrusted,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppPallete.glassWhite10,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppPallete.glassWhite20,
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: AppPallete.glassWhite20,
          child: user.imageUrl != null
              ? ClipOval(
                  child: Image.network(
                    user.imageUrl!,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 24,
                      );
                    },
                  ),
                )
              : Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 24,
                ),
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                user.name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (_isVerifiedUser(user.username)) ...[
              const SizedBox(width: 6),
              const Icon(
                Icons.verified,
                color: Color(0xFF10B981),
                size: 16,
              ),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '@${user.username}',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: user.isOnline 
                        ? Colors.green 
                        : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  user.isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    color: user.isOnline 
                        ? Colors.green 
                        : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: isAlreadyTrusted
            ? Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppPallete.secondaryDark.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppPallete.secondaryDark,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check,
                      color: AppPallete.secondaryDark,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Added',
                      style: TextStyle(
                        color: AppPallete.secondaryDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  color: AppPallete.secondaryDark,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: onAdd,
                  constraints: BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
              ),
      ),
    );
  }

  bool _isVerifiedUser(String username) {
    // Check if username contains thapar.edu or similar patterns for verified users
    return username.toLowerCase().contains('thapar') || 
           username.toLowerCase().contains('tiet');
  }
} 