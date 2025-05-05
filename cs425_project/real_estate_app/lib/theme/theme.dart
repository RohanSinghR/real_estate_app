import 'package:flutter/material.dart';

final ThemeData themeData = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: Color.fromARGB(255, 255, 161, 126), // sunset orange
    onPrimary: Colors.black, // text/icons on primary
    secondary: Color(0xFFFFC36B), // soft golden light
    onSecondary: Colors.black, // text/icons on secondary
    error: Colors.red,
    onError: Colors.white,
    surface: Color(0xFF2C2C2C), // charcoal gray surface
    onSurface: Colors.white, // text/icons on surface
  ),
  scaffoldBackgroundColor: const Color(0xFF0D0D0D),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF2C2C2C),
    foregroundColor: Colors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFFFB27E), // lighter orange for buttons
      foregroundColor: Colors.black, // button text color
    ),
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(color: Colors.white),
    headlineMedium: TextStyle(color: Colors.white),
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white70),
  ),
);
