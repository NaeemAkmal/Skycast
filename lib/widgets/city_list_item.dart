// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../models/city.dart';
import '../models/weather.dart';
import 'weather_icon.dart';

class CityListItem extends StatelessWidget {
  final City city;
  final Weather? weather;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool isSelected;

  const CityListItem({
    required this.city,
    this.weather,
    this.onTap,
    this.onDelete,
    this.isSelected = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      decoration: BoxDecoration(
        color: isSelected ? Color(0xFF22243C) : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(
          city.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Text(
          city.country,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (weather != null)
              Text(
                '${weather!.temp.round()}°',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            const SizedBox(width: 6),
            weather != null
                ? WeatherIcon(iconCode: weather!.icon, size: 32)
                : Icon(Icons.wb_sunny, color: Colors.yellowAccent),
            IconButton(
              icon: const Icon(
                Icons.remove_circle_outline,
                color: Colors.redAccent,
              ),
              onPressed: onDelete,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
