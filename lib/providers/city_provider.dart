import 'package:flutter/material.dart';
import '../models/city.dart';
import '../core/constants.dart';

class CityProvider extends ChangeNotifier {
  final List<City> _cities = initialCities.map((e) => City.fromMap(e)).toList();
  City _selectedCity = City.fromMap(initialCities[0]);
  
  List<City> get cities => _cities;
  City get selectedCity => _selectedCity;

  void addCity(City city) {
    // Check if city already exists
    bool cityExists = _cities.any((c) => 
        c.name.toLowerCase() == city.name.toLowerCase() && 
        c.country.toLowerCase() == city.country.toLowerCase());
    
    if (!cityExists) {
      _cities.add(city);
      print('City added: ${city.name}, ${city.country}');
      notifyListeners();
    } else {
      print('City already exists: ${city.name}');
    }
  }

  void removeCity(City city) {
    if (_cities.length > 1) { // Keep at least one city
      _cities.remove(city);
      
      // If removed city was selected, select the first city
      if (_selectedCity.name == city.name) {
        _selectedCity = _cities.first;
      }
      
      print('City removed: ${city.name}');
      notifyListeners();
    }
  }

  void selectCity(City city) {
    _selectedCity = city;
    print('City selected: ${city.name}');
    notifyListeners();
  }
  
  bool isCitySelected(City city) {
    return _selectedCity.name == city.name && _selectedCity.country == city.country;
  }
}
