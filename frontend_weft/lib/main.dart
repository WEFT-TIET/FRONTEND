import 'package:flutter/material.dart';
import 'package:frontend_weft/core/theme/theme.dart';
import 'package:frontend_weft/features/navbar/navigation.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = true;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WEFT',
      theme: LightAppTheme.lightThemeMode,
      darkTheme: DarkAppTheme.darkThemeMode,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: BottomNavBar(onThemeToggle: _toggleTheme),
    );
  }
}

