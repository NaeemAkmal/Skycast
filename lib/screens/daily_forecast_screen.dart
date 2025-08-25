import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/city_provider.dart';
import '../providers/weather_provider.dart';
import '../models/city.dart';
import '../models/weather.dart';
import '../services/weather_service.dart';
import '../models/forecast.dart';

class DailyForecastScreen extends StatefulWidget {
  const DailyForecastScreen({super.key});

  @override
  State<DailyForecastScreen> createState() => _DailyForecastScreenState();
}

class _DailyForecastScreenState extends State<DailyForecastScreen> {
  List<Forecast> forecasts = [];
  var _hourlyForecast = <Forecast>[];
  int selectedHourIndex = 0;
  WeatherService weatherService = WeatherService();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadForecast();
  }

  Future<void> _loadForecast() async {
    final cityProvider = Provider.of<CityProvider>(context, listen: false);
    City currentCity = cityProvider.selectedCity;

    final forecastData = await weatherService.getDailyForecast(
      currentCity.lat,
      currentCity.lon,
    );
    if (forecastData != null) {
      setState(() {
        forecasts = forecastData.take(5).toList(); // Take first 5 days
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cityProvider = Provider.of<CityProvider>(context);
    final weatherProvider = Provider.of<WeatherProvider>(context);

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
        child: Column(
          children: [
            // Top Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  const Text(
                    'Daily Forecast',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 40), // Balance the back button
                ],
              ),
            ),

            // Hourly Forecast Top Section
            Container(
              height: 130, // Further optimized for mobile
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double availableWidth = constraints.maxWidth;
                  double todayWidth = availableWidth * 0.2; // 20% for Today
                  double hourWidth = (availableWidth - todayWidth - 32) / 4; // Remaining width divided by 4 hours
                  
                  return Row(
                    children: [
                      // Today Column - Responsive width
                      Container(
                        width: todayWidth.clamp(60.0, 80.0), // Min 60, Max 80
                        decoration: BoxDecoration(
                          color: selectedHourIndex == 0 ? const Color(0xFF4A90E2) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              'Today',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: availableWidth > 350 ? 10 : 9,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            _getWeatherIcon(weather.icon, availableWidth > 350 ? 18 : 16),
                            Text(
                              '♦ 25%',
                              style: TextStyle(
                                color: selectedHourIndex == 0 ? Colors.white : Colors.grey,
                                fontSize: availableWidth > 350 ? 8 : 7,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${weather.temp.round()}°',
                              style: TextStyle(
                                color: selectedHourIndex == 0 ? Colors.white : Colors.grey,
                                fontSize: availableWidth > 350 ? 12 : 11,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      
                      // Other hours - Flexible width
                      Expanded(
                        child: Row(
                          children: List.generate(4, (index) {
                            final forecast = _hourlyForecast.isNotEmpty && index < _hourlyForecast.length 
                                ? _hourlyForecast[index] 
                                : null;
                            final tempValue = forecast?.temp.round().toString() ?? '${28 + index}';
                            final precipValue = forecast?.precipitation ?? (25 + index * 10);
                            
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => selectedHourIndex = index + 1),
                                child: Container(
                                  margin: EdgeInsets.only(right: index < 3 ? 4 : 0),
                                  decoration: BoxDecoration(
                                    color: selectedHourIndex == index + 1 ? const Color(0xFF4A90E2) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        '${10 + index}:00',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: availableWidth > 350 ? 10 : 9,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      _getWeatherIcon(
                                        index % 2 == 0 ? '02d' : '01d',
                                        availableWidth > 350 ? 18 : 16,
                                      ),
                                      Text(
                                        '♦ ${precipValue}%',
                                        style: TextStyle(
                                          color: selectedHourIndex == index + 1 ? Colors.white : Colors.grey,
                                          fontSize: availableWidth > 350 ? 8 : 7,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '${tempValue}°',
                                        style: TextStyle(
                                          color: selectedHourIndex == index + 1 ? Colors.white : Colors.grey,
                                          fontSize: availableWidth > 350 ? 12 : 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Day Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF252541),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Day',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              _getWeatherIcon(weather.icon, 40),
                              const SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${weather.temp.round()}°',
                                    style: const TextStyle(
                                      color: Color(0xFF4ECDC4),
                                      fontSize: 24,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  Text(
                                    'Sunshine and\npatchy clouds',
                                    style: TextStyle(
                                      color: Colors.grey[300],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                                size: 16,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: _buildStatColumn('Precipitation', '45%'),
                              ),
                              Expanded(
                                child: _buildStatColumn('Humidity', '84%'),
                              ),
                              Expanded(
                                child: _buildStatColumn('Visibility', '8.3km'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: _buildStatColumn('Dew Point', '26°'),
                              ),
                              Expanded(
                                child: _buildStatColumn('UV Index', 'High (7)'),
                              ),
                              Expanded(
                                child: _buildStatColumn('Cloud Cover', '89%'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Sun/Moon Cycle Widget
                    Container(
                      height: 200,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF252541),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.wb_sunny,
                              color: Colors.orange,
                              size: 40,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Sunrise: 05:42    Sunset: 17:40',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Night Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF252541),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Night',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              _getWeatherIcon('01n', 40), // Night icon
                              const SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${weather.tempMin.round()}°',
                                    style: const TextStyle(
                                      color: Color(0xFF4ECDC4),
                                      fontSize: 24,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  Text(
                                    'Sunshine and\npatchy clouds',
                                    style: TextStyle(
                                      color: Colors.grey[300],
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

                    const SizedBox(height: 20),
                  ],
                ),
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
        iconData = iconCode.contains('n') ? Icons.nights_stay : Icons.wb_sunny;
        iconColor = iconCode.contains('n') ? Colors.blue[300]! : Colors.orange;
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

  Widget _buildStatColumn(String label, String value) {
    return Column(
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
    );
  }
}
