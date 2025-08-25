class Forecast {
  final DateTime date;
  final double temp;
  final double tempMin;
  final double tempMax;
  final String description;
  final String icon;
  final int humidity;
  final int precipitation;
  final double visibility;
  final int cloudCover;

  Forecast({
    required this.date,
    required this.temp,
    required this.tempMin,
    required this.tempMax,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.precipitation,
    required this.visibility,
    required this.cloudCover,
  });
}
