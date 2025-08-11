import 'package:flutter/material.dart';
import 'package:frontend_weft/core/utils/responsive_text_styles.dart';

class ResponsiveProfileName extends StatelessWidget {
  final String name;
  final Color? color;
  final bool isVerified;
  final VoidCallback? onNameTooLong;
  final int maxLength;
  
  const ResponsiveProfileName({
    super.key,
    required this.name,
    this.color,
    this.isVerified = false,
    this.onNameTooLong,
    this.maxLength = 20, // Maximum characters before showing error
  });

  @override
  Widget build(BuildContext context) {
    // Check if name is too long
    if (name.length > maxLength) {
      // Trigger callback if name is too long
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onNameTooLong?.call();
      });
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Use smaller text size for better fitting
        final textStyle = ResponsiveTextStyles.getHeading3(context).copyWith(
          color: color ?? Colors.white,
          fontSize: ResponsiveTextStyles.getHeading3(context).fontSize! * 0.9, // Reduce by 10%
        );
        
        return Row(
          children: [
            Flexible(
              child: Text(
                name,
                style: textStyle,
                overflow: TextOverflow.ellipsis,
                maxLines: 1, // Force single line
              ),
            ),
            if (isVerified) ...[
              const SizedBox(width: 6),
              Icon(
                Icons.verified,
                color: const Color(0xFF10B981),
                size: textStyle.fontSize != null ? textStyle.fontSize! * 0.75 : 16,
              ),
            ],
          ],
        );
      },
    );
  }
}
