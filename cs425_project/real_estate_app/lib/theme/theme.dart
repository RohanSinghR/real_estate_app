import 'package:flutter/material.dart';

final ThemeData themeData = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: Color.fromARGB(255, 255, 161, 126),
    onPrimary: Colors.black,
    secondary: Color(0xFFFFC36B),
    onSecondary: Colors.black,
    error: Colors.red,
    onError: Colors.white,
    surface: Color(0xFF2C2C2C),
    onSurface: Colors.white,
  ),
  scaffoldBackgroundColor: const Color(0xFF0D0D0D),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF2C2C2C),
    foregroundColor: Colors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFFFB27E),
      foregroundColor: Colors.black,
    ),
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(color: Colors.white),
    headlineMedium: TextStyle(color: Colors.white),
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white70),
  ),
);
