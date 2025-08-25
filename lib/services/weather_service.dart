import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:skycast/core/constants.dart';
import '../models/weather.dart';
import '../models/forecast.dart';

class WeatherService {
  Future<Weather?> fetchWeather(double lat, double lon) async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric';
    final response = await http.get(Uri.parse(url));
    print('Calling weather API: $url');
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Weather(
        temp: (data['main']['temp']).toDouble(),
        tempMin: (data['main']['temp_min']).toDouble(),
        tempMax: (data['main']['temp_max']).toDouble(),
        description: data['weather'][0]['description'],
        icon: data['weather'][0]['icon'],
        humidity: data['main']['humidity'],
        precipitation: (data['rain']?['1h'] ?? 0).toInt(),
        visibility: (data['visibility'] / 1000).toDouble(),
        feelsLike: data['main']['feels_like'].toDouble(),
        dewPoint: _calculateDewPoint(data['main']['temp'], data['main']['humidity']),
        uvIndex: 7, // Mock UV index - you can get this from UV API
        cloudCover: data['clouds']['all'],
        date: DateTime.fromMillisecondsSinceEpoch(data['dt'] * 1000),
        sunrise: DateTime.fromMillisecondsSinceEpoch(data['sys']['sunrise'] * 1000),
        sunset: DateTime.fromMillisecondsSinceEpoch(data['sys']['sunset'] * 1000),
      );
    }
    return null;
  }

  Future<List<Forecast>?> getDailyForecast(double lat, double lon) async {
    final url =
        'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric';
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<Forecast> forecasts = [];
      
      for (var item in data['list']) {
        forecasts.add(Forecast(
          date: DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000),
          temp: item['main']['temp'].toDouble(),
          tempMin: item['main']['temp_min'].toDouble(),
          tempMax: item['main']['temp_max'].toDouble(),
          description: item['weather'][0]['description'],
          icon: item['weather'][0]['icon'],
          humidity: item['main']['humidity'],
          precipitation: (item['rain']?['3h'] ?? 0).toInt(),
          visibility: (item['visibility'] / 1000).toDouble(),
          cloudCover: item['clouds']['all'],
        ));
      }
      return forecasts;
    }
    return null;
  }

  Future<List<Forecast>?> getHourlyForecast(double lat, double lon) async {
    final url =
        'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric';
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<Forecast> forecasts = [];
      
      // Get next 5 hourly forecasts
      for (int i = 0; i < 5 && i < data['list'].length; i++) {
        var item = data['list'][i];
        forecasts.add(Forecast(
          date: DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000),
          temp: item['main']['temp'].toDouble(),
          tempMin: item['main']['temp_min'].toDouble(),
          tempMax: item['main']['temp_max'].toDouble(),
          description: item['weather'][0]['description'],
          icon: item['weather'][0]['icon'],
          humidity: item['main']['humidity'],
          precipitation: (item['rain']?['3h'] ?? 0).toInt(),
          visibility: (item['visibility'] / 1000).toDouble(),
          cloudCover: item['clouds']['all'],
        ));
      }
      return forecasts;
    }
    return null;
  }

  double _calculateDewPoint(double temp, int humidity) {
    // Simple dew point calculation
    double a = 17.27;
    double b = 237.7;
    double alpha = ((a * temp) / (b + temp)) + log(humidity / 100);
    return (b * alpha) / (a - alpha);
  }
}
