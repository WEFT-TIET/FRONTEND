import 'package:flutter/material.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';

class DarkAppTheme {
  static final darkThemeMode = ThemeData.dark().copyWith(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppPallete.transperantColor,
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppPallete.transperantColor,
      selectedItemColor: AppPallete.primaryDark,
      unselectedItemColor: AppPallete.textSecondaryDark,
    ),
    cardColor: AppPallete.cardColorDark,
    primaryColor: AppPallete.primaryDark,
    colorScheme: ColorScheme.dark(
      primary: AppPallete.primaryDark,
      secondary: AppPallete.secondaryDark,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppPallete.textPrimaryDark),
      bodyMedium: TextStyle(color: AppPallete.textSecondaryDark),
    ),
    // Extensions for Profile Page
    extensions: [
      ProfileTheme(
        backgroundColor: AppPallete.profileBackgroundDark,
        cardColor: AppPallete.profileCardBackground,
        accentColor: AppPallete.profileAccent,
        textSecondaryColor: AppPallete.profileTextSecondary,
        dialogBackgroundColor: AppPallete.profileDialogBackground,
        glassEffect: GlassEffect(
          primary: AppPallete.glassWhite10,
          secondary: AppPallete.glassWhite05,
          border: AppPallete.glassWhite20,
        ),
      ),
    ],
  );
}

// Custom theme extension for Profile Page
class ProfileTheme extends ThemeExtension<ProfileTheme> {
  final Color backgroundColor;
  final Color cardColor;
  final Color accentColor;
  final Color textSecondaryColor;
  final Color dialogBackgroundColor;
  final GlassEffect glassEffect;

  const ProfileTheme({
    required this.backgroundColor,
    required this.cardColor,
    required this.accentColor,
    required this.textSecondaryColor,
    required this.dialogBackgroundColor,
    required this.glassEffect,
  });

  @override
  ProfileTheme copyWith({
    Color? backgroundColor,
    Color? cardColor,
    Color? accentColor,
    Color? textSecondaryColor,
    Color? dialogBackgroundColor,
    GlassEffect? glassEffect,
  }) {
    return ProfileTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      cardColor: cardColor ?? this.cardColor,
      accentColor: accentColor ?? this.accentColor,
      textSecondaryColor: textSecondaryColor ?? this.textSecondaryColor,
      dialogBackgroundColor: dialogBackgroundColor ?? this.dialogBackgroundColor,
      glassEffect: glassEffect ?? this.glassEffect,
    );
  }

  @override
  ProfileTheme lerp(ThemeExtension<ProfileTheme>? other, double t) {
    if (other is! ProfileTheme) {
      return this;
    }
    return ProfileTheme(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t) ?? backgroundColor,
      cardColor: Color.lerp(cardColor, other.cardColor, t) ?? cardColor,
      accentColor: Color.lerp(accentColor, other.accentColor, t) ?? accentColor,
      textSecondaryColor: Color.lerp(textSecondaryColor, other.textSecondaryColor, t) ?? textSecondaryColor,
      dialogBackgroundColor: Color.lerp(dialogBackgroundColor, other.dialogBackgroundColor, t) ?? dialogBackgroundColor,
      glassEffect: GlassEffect.lerp(glassEffect, other.glassEffect, t),
    );
  }
}

class GlassEffect {
  final Color primary;
  final Color secondary;
  final Color border;

  const GlassEffect({
    required this.primary,
    required this.secondary,
    required this.border,
  });

  static GlassEffect lerp(GlassEffect a, GlassEffect b, double t) {
    return GlassEffect(
      primary: Color.lerp(a.primary, b.primary, t) ?? a.primary,
      secondary: Color.lerp(a.secondary, b.secondary, t) ?? a.secondary,
      border: Color.lerp(a.border, b.border, t) ?? a.border,
    );
  }
}