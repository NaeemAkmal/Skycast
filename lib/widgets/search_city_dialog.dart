import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/city.dart';

class SearchCityDialog extends StatefulWidget {
  const SearchCityDialog({super.key});

  @override
  State<SearchCityDialog> createState() => _SearchCityDialogState();
}

class _SearchCityDialogState extends State<SearchCityDialog> {
  final TextEditingController _controller = TextEditingController();
  List<City> _suggestions = [];
  bool _loading = false;

  Future<void> _searchCities(String query) async {
    if (query.length < 2) {
      setState(() => _suggestions = []);
      return;
    }
    
    setState(() {
      _loading = true;
      _suggestions = [];
    });
    
    try {
      // Clean the query
      final cleanQuery = Uri.encodeQueryComponent(query.trim());
      final url = 'https://api.openweathermap.org/geo/1.0/direct?q=$cleanQuery&limit=8&appid=$apiKey';
      
      print('Searching for: $query');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: 10));
      
      print('Search response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final String body = response.body;
        if (body.isNotEmpty) {
          final list = jsonDecode(body) as List;
          
          if (mounted) {
            setState(() {
              _suggestions = list
                  .where((e) => e['name'] != null && e['country'] != null)
                  .map((e) => City(
                        name: e['name'].toString(),
                        country: e['country'].toString(),
                        lat: (e['lat'] is num) ? e['lat'].toDouble() : 0.0,
                        lon: (e['lon'] is num) ? e['lon'].toDouble() : 0.0,
                      ))
                  .where((city) => city.name.isNotEmpty && city.country.isNotEmpty)
                  .toList();
              _loading = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _suggestions = [];
              _loading = false;
            });
          }
        }
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        if (mounted) {
          setState(() {
            _suggestions = [];
            _loading = false;
          });
        }
      }
    } catch (e) {
      print('Error searching cities: $e');
      if (mounted) {
        setState(() {
          _suggestions = [];
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF22243C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text('Search City', style: TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Type city name (e.g., New York, London)...',
              hintStyle: TextStyle(color: Colors.white60),
              prefixIcon: Icon(Icons.search, color: Colors.white60),
              suffixIcon: _controller.text.isNotEmpty 
                  ? IconButton(
                      icon: Icon(Icons.clear, color: Colors.white60),
                      onPressed: () {
                        _controller.clear();
                        setState(() {
                          _suggestions = [];
                        });
                      },
                    )
                  : null,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white24),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blueAccent, width: 2),
              ),
            ),
            style: TextStyle(color: Colors.white),
            onChanged: (value) {
              setState(() {}); // Refresh UI for clear button
              _searchCities(value);
            },
          ),
          if (_loading)
            Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(color: Colors.blueAccent),
            ),
          if (!_loading && _suggestions.isEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'No results found',
                style: TextStyle(color: Colors.white54),
              ),
            ),
          if (_suggestions.isNotEmpty)
            SizedBox(
              height: 200,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _suggestions.length,
                itemBuilder: (ctx, i) {
                  final city = _suggestions[i];
                  return ListTile(
                    title: Text(
                      '${city.name}, ${city.country}',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () => Navigator.pop(context, city),
                  );
                },
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          child: Text('Close', style: TextStyle(color: Colors.blueAccent)),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
