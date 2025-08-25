// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'weather_icon.dart';

class DailyForecastTabs extends StatelessWidget {
  final List<Map<String, dynamic>> dailyData;
  final int selectedIndex;
  final Function(int) onTabSelected;

  const DailyForecastTabs({
    required this.dailyData,
    required this.selectedIndex,
    required this.onTabSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(dailyData.length, (i) {
        final item = dailyData[i];
        final dt = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
        return GestureDetector(
          onTap: () => onTabSelected(i),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 6),
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: i == selectedIndex
                  ? Colors.blueAccent
                  : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  i == 0 ? 'Today' : '${dt.month}/${dt.day}',
                  style: TextStyle(color: Colors.white),
                ),
                WeatherIcon(iconCode: item['weather'][0]['icon'], size: 24),
                Text(
                  '${item['pop'] != null ? (item['pop'] * 100).round() : 0}%',
                  style: TextStyle(color: Colors.blueAccent, fontSize: 12),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
