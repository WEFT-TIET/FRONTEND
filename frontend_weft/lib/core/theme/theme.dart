import 'package:flutter/material.dart';
import 'package:frontend_weft/core/theme/app_pallete.dart';

class LightAppTheme {
  static final lightThemeMode = ThemeData.light().copyWith(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppPallete.scaffoldBackgroundColorLight,
    cardColor: AppPallete.cardColorLight,
    primaryColor: AppPallete.primaryLight,
    colorScheme: ColorScheme.light(
      primary: AppPallete.primaryLight,
      secondary: AppPallete.secondaryLight,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppPallete.textPrimaryLight),
      bodyMedium: TextStyle(color: AppPallete.textSecondaryLight),
    ),
  );
}

class DarkAppTheme {
  static final darkThemeMode = ThemeData.dark().copyWith(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppPallete.scaffoldBackgroundColorDark,
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
  );
}
