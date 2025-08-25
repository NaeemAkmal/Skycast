import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  ThemeMode get themeMode => _themeMode;

  ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF3B7CFF),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF3B7CFF),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF3B7CFF),
      secondary: Color(0xFF3B7CFF),
    ),
    fontFamily: 'Poppins',
  );

  ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF3B7CFF),
    scaffoldBackgroundColor: const Color(0xFF181A2A),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF181A2A),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF3B7CFF),
      secondary: Color(0xFF3B7CFF),
    ),
    fontFamily: 'Poppins',
  );

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    notifyListeners();
  }
}
