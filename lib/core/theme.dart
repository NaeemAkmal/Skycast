import 'package:flutter/material.dart';

const blueAccent = Color(0xFF3B7CFF);

final lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: blueAccent,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: AppBarTheme(
    backgroundColor: blueAccent,
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  colorScheme: ColorScheme.light(
    primary: blueAccent,
    secondary: blueAccent,
  ),
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: blueAccent,
  scaffoldBackgroundColor: Color(0xFF181A2A),
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xFF181A2A),
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  colorScheme: ColorScheme.dark(
    primary: blueAccent,
    secondary: blueAccent,
  ),
);