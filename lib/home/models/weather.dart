import 'package:intl/intl.dart';

class Weather {
  final String description;
  final int temperature;
  final double humidity;
  final int visibility;
  final int pressure;
  final int tempMax;
  final int tempMin;
  final String? sunrise;
  final String? sunset;

  Weather({
    required this.description,
    required this.temperature,
    required this.humidity,
    required this.visibility,
    required this.pressure,
    required this.tempMax,
    required this.tempMin,
    required this.sunrise,
    required this.sunset
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      description: json['weather'][0]['description'],
      temperature: (json['main']['temp'] as num).round(),
      humidity: (json['main']['humidity'] as num).toDouble(),
      visibility: json['visibility'] as int,
      pressure: json['main']['pressure'] as int,
      tempMax: (json['main']['temp_max'] as num).round(),
      tempMin: (json['main']['temp_min'] as num).round(),
      sunrise: DateFormat('hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(json['sys']['sunrise'] * 1000)),
      sunset: DateFormat('hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(json['sys']['sunset'] * 1000)),
    );
  }
}
