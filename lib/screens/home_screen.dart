import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/city_provider.dart';
import '../providers/weather_provider.dart';
import '../models/city.dart';
import '../models/weather.dart';
import '../services/weather_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = true;
  WeatherService weatherService = WeatherService();

  @override
  void initState() {
    super.initState();
    // Use post-frame callback to avoid setState during build
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeWeatherData();
      }
    });
  }

  void _initializeWeatherData() async {
    final cityProvider = Provider.of<CityProvider>(context, listen: false);
    final weatherProvider = Provider.of<WeatherProvider>(
      context,
      listen: false,
    );

    Weather? existingWeather = weatherProvider.getWeather(
      cityProvider.selectedCity,
    );

    if (existingWeather != null) {
      // Data exists, no need to load
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    } else {
      // Data doesn't exist, load it
      await _loadWeather();
    }
  }

  Future<void> _loadWeather() async {
    final cityProvider = Provider.of<CityProvider>(context, listen: false);
    final weatherProvider = Provider.of<WeatherProvider>(
      context,
      listen: false,
    );

    try {
      await weatherProvider.fetchAllWeather(cityProvider.cities);

      // Load hourly forecast for selected city
      City currentCity = cityProvider.selectedCity;
      final hourlyData = await weatherService.getHourlyForecast(
        currentCity.lat,
        currentCity.lon,
      );
      if (hourlyData != null) {}
    } catch (e) {
      print('Error loading weather: $e');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var cityProvider = Provider.of<CityProvider>(context);
    var weatherProvider = Provider.of<WeatherProvider>(context);

    City currentCity = cityProvider.selectedCity;
    Weather? weather = weatherProvider.getWeather(currentCity);

    if (_loading || weather == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF1C1C2E),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF4A90E2)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1C1C2E),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.menu,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () => Navigator.pushNamed(context, '/menu'),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            currentCity.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            DateFormat('EEE dd MMM').format(DateTime.now()),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () =>
                          Navigator.pushNamed(context, '/locations'),
                    ),
                  ],
                ),
              ),

              // Main Weather Display
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    // Weather Icon
                    Container(
                      width: 80,
                      height: 80,
                      child: _getWeatherIcon(weather.icon, 80),
                    ),
                    const SizedBox(width: 20),
                    // Temperature and Details
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${weather.temp.round()}°',
                          style: const TextStyle(
                            color: Color(0xFF4ECDC4),
                            fontSize: 48,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        Text(
                          _getWeatherStatus(weather.description),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${weather.tempMax.round()}° / ${weather.tempMin.round()}°',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Feel like ${weather.feelsLike.round()}°',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Hourly Forecast Section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hourly Forecast',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 120, // Increased height to fix overflow
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          return Container(
                            width: 60,
                            margin: const EdgeInsets.only(right: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  index == 0 ? '06:00' : '${6 + index}:00',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                                _getWeatherIcon(
                                  index % 2 == 0 ? '01d' : '02d',
                                  24,
                                ),
                                Text(
                                  '♦ ${20 + index}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10, // Reduced font size
                                  ),
                                ),
                                Text(
                                  '${29 + index}°',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14, // Reduced font size
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Temperature Line Chart
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF252541),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    'Temperature Chart',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Current Weather Stats
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF252541),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current weather',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatItem(
                          'Precipitation',
                          '${weather.precipitation}%',
                        ),
                        _buildStatItem('Humidity', '${weather.humidity}%'),
                        _buildStatItem('Visibility', '${weather.visibility}km'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatItem(
                          'Dew Point',
                          '${weather.dewPoint.round()}°',
                        ),
                        _buildStatItem('UV Index', 'High (${weather.uvIndex})'),
                        _buildStatItem('Cloud Cover', '${weather.cloudCover}%'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Navigate to Daily Forecast Button
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A90E2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'View Daily Forecast',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/forecast');
                  },
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
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

  String _getWeatherStatus(String description) {
    // Convert to title case and return
    return description
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  Widget _buildStatItem(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 11, // Reduced font size
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13, // Reduced font size
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
