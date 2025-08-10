import 'package:flutter/material.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';
import '../models/trusted_user_model.dart';

class TrustedUserTile extends StatelessWidget {
  final TrustedUserModel user;
  final VoidCallback onRemove;

  const TrustedUserTile({
    super.key,
    required this.user,
    required this.onRemove,
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
            Expanded(
              child: Row(
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
            ),
            if (user.isGhostMode)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppPallete.secondaryDark.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppPallete.secondaryDark,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.visibility_off,
                      color: AppPallete.secondaryDark,
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Ghost',
                      style: TextStyle(
                        color: AppPallete.secondaryDark,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
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
                if (user.latitude != null && user.longitude != null && !user.isGhostMode)
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.location_on,
                          color: AppPallete.secondaryDark,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Location shared',
                          style: TextStyle(
                            color: AppPallete.secondaryDark,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            color: Colors.white70,
          ),
          color: AppPallete.profileDialogBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'remove',
              child: Row(
                children: [
                  Icon(
                    Icons.person_remove,
                    color: AppPallete.red,
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Remove from trusted list',
                    style: TextStyle(
                      color: AppPallete.red,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'remove') {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppPallete.profileDialogBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Text(
                    'Remove User',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  content: Text(
                    'Are you sure you want to remove ${user.name} from your trusted list?',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onRemove();
                      },
                      child: Text(
                        'Remove',
                        style: TextStyle(
                          color: AppPallete.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
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