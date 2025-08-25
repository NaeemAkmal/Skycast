class Weather {
  final double temp;
  final double tempMin;
  final double tempMax;
  final String description;
  final String icon;
  final int humidity;
  final int precipitation;
  final double visibility;
  final double feelsLike;
  final double dewPoint;
  final int uvIndex;
  final int cloudCover;
  final DateTime date;
  final DateTime? sunrise;
  final DateTime? sunset;

  Weather({
    required this.temp,
    required this.tempMin,
    required this.tempMax,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.precipitation,
    required this.visibility,
    required this.feelsLike,
    required this.dewPoint,
    required this.uvIndex,
    required this.cloudCover,
    required this.date,
    this.sunrise,
    this.sunset,
  });
}
