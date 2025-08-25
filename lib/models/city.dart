class City {
  final String name;
  final String country;
  final double lat;
  final double lon;

  const City({
    required this.name,
    required this.country,
    required this.lat,
    required this.lon,
  });

  factory City.fromMap(Map<String, dynamic> map) => City(
    name: map['name'],
    country: map['country'],
    lat: map['lat'],
    lon: map['lon'],
  );
}
