import 'package:flutter/material.dart';
import 'package:frontend_weft/core/utils/responsive_utils.dart';

class ResponsiveTextStyles {
  static TextStyle getHeading1(BuildContext context) {
    return TextStyle(
      fontSize: context.responsiveFontSize(28),
      fontWeight: FontWeight.bold,
      letterSpacing: 0.5,
      height: 1.2,
    );
  }
  
  static TextStyle getHeading2(BuildContext context) {
    return TextStyle(
      fontSize: context.responsiveFontSize(24),
      fontWeight: FontWeight.bold,
      letterSpacing: 0.5,
      height: 1.3,
    );
  }
  
  static TextStyle getHeading3(BuildContext context) {
    return TextStyle(
      fontSize: context.responsiveFontSize(20),
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
      height: 1.4,
    );
  }
  
  static TextStyle getBodyLarge(BuildContext context) {
    return TextStyle(
      fontSize: context.responsiveFontSize(16),
      fontWeight: FontWeight.w500,
      letterSpacing: 0.2,
      height: 1.5,
    );
  }
  
  static TextStyle getBodyMedium(BuildContext context) {
    return TextStyle(
      fontSize: context.responsiveFontSize(14),
      fontWeight: FontWeight.w400,
      letterSpacing: 0.2,
      height: 1.4,
    );
  }
  
  static TextStyle getBodySmall(BuildContext context) {
    return TextStyle(
      fontSize: context.responsiveFontSize(12),
      fontWeight: FontWeight.w400,
      letterSpacing: 0.1,
      height: 1.4,
    );
  }
  
  static TextStyle getCaption(BuildContext context) {
    return TextStyle(
      fontSize: context.responsiveFontSize(11),
      fontWeight: FontWeight.w400,
      letterSpacing: 0.1,
      height: 1.3,
    );
  }
  
  static TextStyle getButton(BuildContext context) {
    return TextStyle(
      fontSize: context.responsiveFontSize(14),
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
      height: 1.2,
    );
  }
  
  static TextStyle getUsername(BuildContext context) {
    return TextStyle(
      fontSize: context.responsiveFontSize(14), // Reduced from 16
      fontWeight: FontWeight.w500,
      letterSpacing: 0.2,
      height: 1.3,
    );
  }
  
  static TextStyle getName(BuildContext context) {
    return TextStyle(
      fontSize: context.responsiveFontSize(20), // Reduced from 24
      fontWeight: FontWeight.bold,
      letterSpacing: 0.3,
      height: 1.2,
    );
  }
  
  static TextStyle getFieldLabel(BuildContext context) {
    return TextStyle(
      fontSize: context.responsiveFontSize(14),
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
      height: 1.4,
    );
  }
}
