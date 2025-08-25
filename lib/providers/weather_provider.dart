import 'package:flutter/material.dart';
import '../models/weather.dart';
import '../models/city.dart';
import '../services/weather_service.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherService _service = WeatherService();
  final Map<String, Weather?> _weatherMap = {};
  final Map<String, DateTime> _lastFetchTime = {};
  bool _isLoading = false;
  String? _error;
  
  Map<String, Weather?> get weatherMap => _weatherMap;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Cache duration - 5 minutes
  static const Duration _cacheTimeout = Duration(minutes: 5);

  Future<void> fetchAllWeather(List<City> cities) async {
    if (_isLoading) return; // Prevent multiple simultaneous calls
    
    _isLoading = true;
    _error = null;
    
    try {
      for (var city in cities) {
        final lastFetch = _lastFetchTime[city.name];
        final shouldUpdate = lastFetch == null || 
            DateTime.now().difference(lastFetch) > _cacheTimeout ||
            _weatherMap[city.name] == null;
            
        if (shouldUpdate) {
          print('Fetching weather for ${city.name}');
          final w = await _service.fetchWeather(city.lat, city.lon);
          _weatherMap[city.name] = w;
          _lastFetchTime[city.name] = DateTime.now();
        } else {
          print('Using cached weather for ${city.name}');
        }
      }
      
    } catch (e) {
      print('Error fetching weather: $e');
      _error = 'Failed to fetch weather data';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> fetchWeatherForCity(City city) async {
    final lastFetch = _lastFetchTime[city.name];
    final shouldUpdate = lastFetch == null || 
        DateTime.now().difference(lastFetch) > _cacheTimeout ||
        _weatherMap[city.name] == null;
        
    if (!shouldUpdate) {
      print('Using cached weather for ${city.name}');
      return;
    }
    
    try {
      print('Fetching weather for single city: ${city.name}');
      final w = await _service.fetchWeather(city.lat, city.lon);
      _weatherMap[city.name] = w;
      _lastFetchTime[city.name] = DateTime.now();
      notifyListeners();
    } catch (e) {
      print('Error fetching weather for ${city.name}: $e');
    }
  }

  Weather? getWeather(City city) => _weatherMap[city.name];
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
