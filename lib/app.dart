// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skycast/screens/location_screen.dart';

import 'core/theme.dart';
import 'screens/home_screen.dart';
import 'screens/daily_forecast_screen.dart';
import 'screens/menu_screen.dart';
import 'providers/city_provider.dart';
import 'providers/weather_provider.dart';

class SkyCastApp extends StatelessWidget {
  const SkyCastApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkyCast',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.dark, // Force dark mode to match our UI
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/forecast': (context) => const DailyForecastScreen(),
        '/locations': (context) => const LocationsScreen(),
        '/menu': (context) => const MenuScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
