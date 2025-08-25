import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/city_provider.dart';
import '../providers/weather_provider.dart';
import '../models/city.dart';

import '../widgets/search_city_dialog.dart';

class LocationsScreen extends StatefulWidget {
  const LocationsScreen({super.key});

  @override
  State<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen> {
  @override
  void initState() {
    super.initState();
    // Don't automatically fetch weather here as it causes excessive API calls
    // Weather will be loaded on-demand when the home screen is opened
  }

  @override
  Widget build(BuildContext context) {
    var cityProvider = Provider.of<CityProvider>(context);
    var weatherProvider = Provider.of<WeatherProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Location management',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: const Color(0xFF1C1C2E),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white, size: 20),
            onPressed: () => Navigator.pushNamed(context, '/menu'),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF1C1C2E),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: cityProvider.cities.length,
              itemBuilder: (context, index) {
                City city = cityProvider.cities[index];
                var weather = weatherProvider.getWeather(city);
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF252541),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Dismissible(
                    key: Key(city.name),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      // Prevent deleting the last city
                      if (cityProvider.cities.length <= 1) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Cannot delete the last city!'),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 2),
                          ),
                        );
                        return false;
                      }
                      
                      // Show confirmation dialog
                      return await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: const Color(0xFF252541),
                          title: const Text(
                            'Delete City',
                            style: TextStyle(color: Colors.white),
                          ),
                          content: Text(
                            'Are you sure you want to delete ${city.name}?',
                            style: TextStyle(color: Colors.grey[300]),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ) ?? false;
                    },
                    onDismissed: (direction) {
                      // If this was the selected city, select another one
                      if (cityProvider.selectedCity.name == city.name && cityProvider.cities.length > 1) {
                        City newSelectedCity = cityProvider.cities.firstWhere(
                          (c) => c.name != city.name,
                        );
                        cityProvider.selectCity(newSelectedCity);
                      }
                      
                      // Remove the city
                      cityProvider.removeCity(city);
                      
                      // Show confirmation
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${city.name} deleted successfully!'),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 2),
                          action: SnackBarAction(
                            label: 'Undo',
                            textColor: Colors.white,
                            onPressed: () {
                              cityProvider.addCity(city);
                            },
                          ),
                        ),
                      );
                    },
                    child: InkWell(
                      onTap: () {
                        cityProvider.selectCity(city);
                        Navigator.pop(context);
                      },
                      onLongPress: () {
                        _showCityOptionsMenu(context, city, cityProvider, weatherProvider);
                      },
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      city.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (cityProvider.selectedCity.name == city.name)
                                      const Icon(
                                        Icons.check_circle,
                                        color: Color(0xFF4A90E2),
                                        size: 16,
                                      )
                                    else
                                      const Icon(
                                        Icons.location_on,
                                        color: Color(0xFF4A90E2),
                                        size: 16,
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${city.country}',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              if (weather != null) ...[
                                _getWeatherIcon(weather.icon),
                                const SizedBox(height: 4),
                                Text(
                                  '${weather.temp.round()}°',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ] else ..[
                                IconButton(
                                  onPressed: () async {
                                    try {
                                      await weatherProvider.fetchWeatherForCity(city);
                                    } catch (e) {
                                      print('Error refreshing weather: $e');
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.refresh,
                                    color: Color(0xFF4A90E2),
                                    size: 20,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.add, size: 20),
                label: const Text(
                  'Add City',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                onPressed: () async {
                  City? newCity = await showDialog(
                    context: context,
                    builder: (_) => const SearchCityDialog(),
                  );
                  if (newCity != null && mounted) {
                    cityProvider.addCity(newCity);
                    // Fetch weather for new city immediately
                    try {
                      await weatherProvider.fetchWeatherForCity(newCity);
                      print('Weather fetched successfully for ${newCity.name}');
                    } catch (e) {
                      print('Error fetching weather for new city: $e');
                    }

                    // Show confirmation
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${newCity.name} added successfully!'),
                          backgroundColor: const Color(0xFF4A90E2),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getWeatherIcon(String iconCode) {
    IconData iconData;
    switch (iconCode.substring(0, 2)) {
      case '01': // clear sky
        iconData = Icons.wb_sunny;
        break;
      case '02': // few clouds
      case '03': // scattered clouds
      case '04': // broken clouds
        iconData = Icons.cloud;
        break;
      case '09': // shower rain
      case '10': // rain
        iconData = Icons.grain;
        break;
      case '11': // thunderstorm
        iconData = Icons.flash_on;
        break;
      case '13': // snow
        iconData = Icons.ac_unit;
        break;
      case '50': // mist
        iconData = Icons.blur_on;
        break;
      default:
        iconData = Icons.wb_sunny;
    }
    return Icon(iconData, color: Colors.orange, size: 24);
  }

  void _showCityOptionsMenu(BuildContext context, City city, CityProvider cityProvider, WeatherProvider weatherProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF252541),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              city.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.check_circle, color: Color(0xFF4A90E2)),
            title: const Text(
              'Select City',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              cityProvider.selectCity(city);
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.refresh, color: Color(0xFF4A90E2)),
            title: const Text(
              'Refresh Weather',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () async {
              Navigator.pop(context);
              try {
                await weatherProvider.fetchWeatherForCity(city);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Weather updated for ${city.name}'),
                      backgroundColor: const Color(0xFF4A90E2),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update weather for ${city.name}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
          if (cityProvider.cities.length > 1)
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Delete City',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteCity(context, city, cityProvider);
              },
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _confirmDeleteCity(BuildContext context, City city, CityProvider cityProvider) async {
    bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF252541),
        title: const Text(
          'Delete City',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete ${city.name}?',
          style: TextStyle(color: Colors.grey[300]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (shouldDelete == true && mounted) {
      // If this was the selected city, select another one
      if (cityProvider.selectedCity.name == city.name && cityProvider.cities.length > 1) {
        City newSelectedCity = cityProvider.cities.firstWhere(
          (c) => c.name != city.name,
        );
        cityProvider.selectCity(newSelectedCity);
      }
      
      // Remove the city
      cityProvider.removeCity(city);
      
      // Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${city.name} deleted successfully!'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
