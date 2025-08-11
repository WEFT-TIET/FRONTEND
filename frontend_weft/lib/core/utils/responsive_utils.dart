import 'package:flutter/material.dart';
import 'dart:math' as math;

class ResponsiveUtils {
  static double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
  static double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;
  static double screenDensity(BuildContext context) => MediaQuery.of(context).devicePixelRatio;
  
  // Screen size breakpoints
  static bool isSmallScreen(BuildContext context) => screenWidth(context) < 375;
  static bool isMediumScreen(BuildContext context) => screenWidth(context) >= 375 && screenWidth(context) <= 414;
  static bool isLargeScreen(BuildContext context) => screenWidth(context) > 414;
  
  // Responsive font sizes
  static double getFontSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / 375.0; // Base width (iPhone 6/7/8)
    return baseSize * math.min(math.max(scaleFactor, 0.8), 1.4); // Min 0.8x, Max 1.4x
  }
  
  // Responsive padding
  static EdgeInsets getResponsivePadding(BuildContext context, {
    double horizontal = 16,
    double vertical = 16,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalScale = screenWidth / 375.0;
    final verticalScale = MediaQuery.of(context).size.height / 812.0;
    
    return EdgeInsets.symmetric(
      horizontal: horizontal * math.min(math.max(horizontalScale, 0.8), 1.2),
      vertical: vertical * math.min(math.max(verticalScale, 0.8), 1.2),
    );
  }
  
  // Responsive margins
  static EdgeInsets getResponsiveMargin(BuildContext context, {
    double horizontal = 16,
    double vertical = 16,
  }) {
    return getResponsivePadding(context, horizontal: horizontal, vertical: vertical);
  }
  
  // Responsive height for components
  static double getResponsiveHeight(BuildContext context, double baseHeight) {
    final screenHeight = MediaQuery.of(context).size.height;
    final scaleFactor = screenHeight / 812.0; // Base height (iPhone X)
    return baseHeight * math.min(math.max(scaleFactor, 0.8), 1.2);
  }
  
  // Responsive width for components  
  static double getResponsiveWidth(BuildContext context, double baseWidth) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / 375.0; // Base width
    return baseWidth * math.min(math.max(scaleFactor, 0.8), 1.2);
  }
  
  // Responsive border radius
  static BorderRadius getResponsiveBorderRadius(BuildContext context, double baseRadius) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / 375.0;
    final responsiveRadius = baseRadius * math.min(math.max(scaleFactor, 0.8), 1.2);
    return BorderRadius.circular(responsiveRadius);
  }
  
  // Responsive icon size
  static double getIconSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / 375.0;
    return baseSize * math.min(math.max(scaleFactor, 0.8), 1.3);
  }
  
  // Responsive spacing between elements
  static double getSpacing(BuildContext context, double baseSpacing) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / 375.0;
    return baseSpacing * math.min(math.max(scaleFactor, 0.8), 1.2);
  }
  
  // Get appropriate image size for profile pictures
  static double getProfileImageSize(BuildContext context, {double baseSize = 80}) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 350) return baseSize * 0.9;
    if (screenWidth > 450) return baseSize * 1.1;
    return baseSize;
  }
  
  // Get responsive container padding for cards
  static EdgeInsets getCardPadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 350) return const EdgeInsets.all(12);
    if (screenWidth > 450) return const EdgeInsets.all(20);
    return const EdgeInsets.all(16);
  }
  
  // Get responsive button height
  static double getButtonHeight(BuildContext context, {double baseHeight = 48}) {
    final screenHeight = MediaQuery.of(context).size.height;
    if (screenHeight < 700) return baseHeight * 0.9;
    if (screenHeight > 900) return baseHeight * 1.1;
    return baseHeight;
  }
  
  // Safe area aware padding
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    final safePadding = MediaQuery.of(context).padding;
    return EdgeInsets.only(
      top: safePadding.top,
      bottom: safePadding.bottom,
    );
  }
  
  // Get responsive text field height
  static double getTextFieldHeight(BuildContext context, {double baseHeight = 56}) {
    final screenHeight = MediaQuery.of(context).size.height;
    if (screenHeight < 700) return baseHeight * 0.9;
    if (screenHeight > 900) return baseHeight * 1.1;
    return baseHeight;
  }
  
  // Check if device has a notch or dynamic island
  static bool hasNotch(BuildContext context) {
    return MediaQuery.of(context).padding.top > 24;
  }
  
  // Get responsive app bar height
  static double getAppBarHeight(BuildContext context) {
    if (hasNotch(context)) return 96;
    return 80;
  }
}

// Extension to easily access responsive utilities
extension ResponsiveExtension on BuildContext {
  double get screenWidth => ResponsiveUtils.screenWidth(this);
  double get screenHeight => ResponsiveUtils.screenHeight(this);
  bool get isSmallScreen => ResponsiveUtils.isSmallScreen(this);
  bool get isMediumScreen => ResponsiveUtils.isMediumScreen(this);
  bool get isLargeScreen => ResponsiveUtils.isLargeScreen(this);
  bool get hasNotch => ResponsiveUtils.hasNotch(this);
  
  double responsiveFontSize(double baseSize) => ResponsiveUtils.getFontSize(this, baseSize);
  EdgeInsets responsivePadding({double horizontal = 16, double vertical = 16}) => 
    ResponsiveUtils.getResponsivePadding(this, horizontal: horizontal, vertical: vertical);
  EdgeInsets responsiveMargin({double horizontal = 16, double vertical = 16}) => 
    ResponsiveUtils.getResponsiveMargin(this, horizontal: horizontal, vertical: vertical);
  double responsiveHeight(double baseHeight) => ResponsiveUtils.getResponsiveHeight(this, baseHeight);
  double responsiveWidth(double baseWidth) => ResponsiveUtils.getResponsiveWidth(this, baseWidth);
  BorderRadius responsiveBorderRadius(double baseRadius) => ResponsiveUtils.getResponsiveBorderRadius(this, baseRadius);
  double responsiveIconSize(double baseSize) => ResponsiveUtils.getIconSize(this, baseSize);
  double responsiveSpacing(double baseSpacing) => ResponsiveUtils.getSpacing(this, baseSpacing);
}
