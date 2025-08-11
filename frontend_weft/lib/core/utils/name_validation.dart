import 'package:flutter/material.dart';
import 'package:frontend_weft/core/utils/responsive_text_styles.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';

class NameValidationHelper {
  static const int maxNameLength = 20;
  static const int maxUsernameLength = 15;
  
  static bool isNameTooLong(String name) {
    return name.length > maxNameLength;
  }
  
  static bool isUsernameTooLong(String username) {
    return username.length > maxUsernameLength;
  }
  
  static String getNameError(String name) {
    if (name.isEmpty) return 'Name cannot be empty';
    if (isNameTooLong(name)) return 'Name too long (max $maxNameLength characters)';
    return '';
  }
  
  static String getUsernameError(String username) {
    if (username.isEmpty) return 'Username cannot be empty';
    if (isUsernameTooLong(username)) return 'Username too long (max $maxUsernameLength characters)';
    if (username.contains(' ')) return 'Username cannot contain spaces';
    return '';
  }
}

class ProfileNameErrorWidget extends StatelessWidget {
  final String errorMessage;
  
  const ProfileNameErrorWidget({
    super.key,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (errorMessage.isEmpty) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppPallete.red.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppPallete.red.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: AppPallete.red,
            size: 16,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              errorMessage,
              style: ResponsiveTextStyles.getBodySmall(context).copyWith(
                color: AppPallete.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
