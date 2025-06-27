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
  );
}
