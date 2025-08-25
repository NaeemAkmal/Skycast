import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/city_provider.dart';
import '../providers/weather_provider.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cityProvider = Provider.of<CityProvider>(context);
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final selectedCity = cityProvider.selectedCity;
    final weather = weatherProvider.getWeather(selectedCity);

    return Scaffold(
      backgroundColor: const Color(0xFF1C1C2E),
      body: SafeArea(
        child: Column(
          children: [
            // Header with weather info
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Weather icon and temperature
                  Row(
                    children: [
                      _getWeatherIcon(weather?.icon ?? '01d', 60),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedCity.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            weather != null
                                ? '${weather.tempMax.round()}° / ${weather.tempMin.round()}°'
                                : 'Loading...',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            DateTime.now().toString().split(' ')[0],
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Cities List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // Display all cities
                  ...cityProvider.cities.map((city) {
                    final cityWeather = weatherProvider.getWeather(city);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(
                          city.name,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          cityWeather != null
                              ? '${cityWeather.tempMax.round()}° / ${cityWeather.tempMin.round()}°'
                              : 'Loading...',
                          style: const TextStyle(color: Colors.white54),
                        ),
                        trailing: _getWeatherIcon(
                          cityWeather?.icon ?? '01d',
                          24,
                        ),
                        onTap: () {
                          cityProvider.selectCity(city);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  }),

                  const SizedBox(height: 20),

                  // Add City Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A90E2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      'Add City',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/locations');
                    },
                  ),

                  const SizedBox(height: 30),
                  const Divider(color: Colors.white24),

                  // Menu Options
                  ListTile(
                    leading: const Icon(Icons.share, color: Colors.white),
                    title: const Text(
                      'Share your weather',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () => _shareWeather(context, selectedCity, weather),
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings, color: Colors.white),
                    title: const Text(
                      'Setting',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () => _showSettingsDialog(context),
                  ),
                  ListTile(
                    leading: const Icon(Icons.star, color: Colors.white),
                    title: const Text(
                      'Rate me',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () => _rateApp(context),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.info_outline,
                      color: Colors.white,
                    ),
                    title: const Text(
                      'Version',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: const Text(
                      '1.0.0',
                      style: TextStyle(color: Colors.white54),
                    ),
                    onTap: () => _showAboutDialog(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getWeatherIcon(String iconCode, double size) {
    IconData iconData;
    Color iconColor = Colors.orange;

    switch (iconCode.substring(0, 2)) {
      case '01': // clear sky
        iconData = Icons.wb_sunny;
        iconColor = Colors.orange;
        break;
      case '02': // few clouds
      case '03': // scattered clouds
      case '04': // broken clouds
        iconData = Icons.cloud;
        iconColor = Colors.grey;
        break;
      case '09': // shower rain
      case '10': // rain
        iconData = Icons.grain;
        iconColor = Colors.blue;
        break;
      case '11': // thunderstorm
        iconData = Icons.flash_on;
        iconColor = Colors.yellow;
        break;
      case '13': // snow
        iconData = Icons.ac_unit;
        iconColor = Colors.white;
        break;
      case '50': // mist
        iconData = Icons.blur_on;
        iconColor = Colors.grey;
        break;
      default:
        iconData = Icons.wb_sunny;
    }

    return Icon(iconData, color: iconColor, size: size);
  }

  void _shareWeather(BuildContext context, city, weather) {
    if (weather != null) {
      final message =
          'Weather in ${city.name}: ${weather.temp.round()}°C, ${weather.description}. Powered by SkyCast Weather App!';
      Share.share(message);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Weather data not available'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF252541),
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Settings will be available in future updates.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Color(0xFF4A90E2))),
          ),
        ],
      ),
    );
  }

  void _rateApp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF252541),
        title: const Text(
          'Rate SkyCast',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Thank you for using SkyCast! Please rate us on the app store.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // In a real app, you would launch the app store
            },
            child: const Text(
              'Rate Now',
              style: TextStyle(color: Color(0xFF4A90E2)),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF252541),
        title: const Text(
          'About SkyCast',
          style: TextStyle(color: Colors.white),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SkyCast Weather App\nVersion 1.0.0\n\nA beautiful and functional weather app built with Flutter.',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 10),
            Text(
              'Powered by OpenWeatherMap API',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Color(0xFF4A90E2))),
          ),
        ],
      ),
    );
  }
}
