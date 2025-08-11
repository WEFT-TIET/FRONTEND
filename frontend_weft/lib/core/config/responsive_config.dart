import 'package:flutter/material.dart';
import 'package:frontend_weft/core/utils/responsive_utils.dart';

class ResponsiveConfig {
  static void configureApp() {
    // Force all screens to portrait mode only (this helps with consistency)
    // This will be called from main.dart
  }
  
  // Global responsive breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;
  
  // Standard spacing values
  static const double spacingXS = 4;
  static const double spacingS = 8;
  static const double spacingM = 16;
  static const double spacingL = 24;
  static const double spacingXL = 32;
  static const double spacingXXL = 48;
  
  // Standard radius values
  static const double radiusS = 8;
  static const double radiusM = 12;
  static const double radiusL = 16;
  static const double radiusXL = 20;
  static const double radiusXXL = 24;
  
  // Standard component heights
  static const double buttonHeight = 56;
  static const double inputHeight = 56;
  static const double appBarHeight = 80;
  static const double navBarHeight = 60;
  
  // Profile specific sizes
  static const double profileImageSizeS = 60;
  static const double profileImageSizeM = 80;
  static const double profileImageSizeL = 100;
  static const double profileImageSizeXL = 120;
  
  // Get device type
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return DeviceType.mobile;
    if (width < tabletBreakpoint) return DeviceType.tablet;
    return DeviceType.desktop;
  }
  
  // Get profile image size based on screen size
  static double getProfileImageSize(BuildContext context, ProfileImageSize size) {
    final deviceType = getDeviceType(context);
    final scaleFactor = _getScaleFactor(context);
    
    double baseSize;
    switch (size) {
      case ProfileImageSize.small:
        baseSize = profileImageSizeS;
        break;
      case ProfileImageSize.medium:
        baseSize = profileImageSizeM;
        break;
      case ProfileImageSize.large:
        baseSize = profileImageSizeL;
        break;
      case ProfileImageSize.extraLarge:
        baseSize = profileImageSizeXL;
        break;
    }
    
    // Adjust based on device type
    switch (deviceType) {
      case DeviceType.mobile:
        return baseSize * scaleFactor;
      case DeviceType.tablet:
        return baseSize * scaleFactor * 1.1;
      case DeviceType.desktop:
        return baseSize * scaleFactor * 1.2;
    }
  }
  
  static double _getScaleFactor(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final baseFactor = screenWidth / 375.0; // iPhone 6/7/8 width
    return baseFactor.clamp(0.8, 1.4);
  }
  
  // Get responsive padding based on content type
  static EdgeInsets getContentPadding(BuildContext context, ContentType type) {
    final spacing = ResponsiveUtils.getSpacing(context, spacingM);
    
    switch (type) {
      case ContentType.page:
        return EdgeInsets.symmetric(horizontal: spacing, vertical: spacing);
      case ContentType.card:
        return EdgeInsets.all(spacing);
      case ContentType.form:
        return EdgeInsets.symmetric(horizontal: spacing * 1.5, vertical: spacing);
      case ContentType.dialog:
        return EdgeInsets.all(spacing * 1.25);
    }
  }
  
  // Standard animation durations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
}

enum DeviceType { mobile, tablet, desktop }
enum ProfileImageSize { small, medium, large, extraLarge }
enum ContentType { page, card, form, dialog }
