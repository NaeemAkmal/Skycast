// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'weather_icon.dart';

class HourlyForecast extends StatelessWidget {
  final List<Map<String, dynamic>> hourlyData;

  const HourlyForecast({required this.hourlyData, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: hourlyData.length,
        itemBuilder: (ctx, i) {
          final item = hourlyData[i];
          final dt = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
          return Container(
            width: 70,
            margin: EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${dt.hour}:00', style: TextStyle(color: Colors.white)),
                WeatherIcon(iconCode: item['weather'][0]['icon'], size: 32),
                Text(
                  '${item['main']['temp'].round()}°',
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  '${item['pop'] != null ? (item['pop'] * 100).round() : 0}%',
                  style: TextStyle(color: Colors.blueAccent, fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
