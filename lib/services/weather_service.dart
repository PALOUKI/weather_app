import 'dart:convert';
import 'package:http/http.dart' as http;

import '../home/models/location_data.dart';
import '../home/models/weather.dart';


class WeatherService {
  final String apiKeyWeather = 'aeab799de0eedd303d1f24c3b1a11dcf';
  final String apiKeyGeocoding = 'c58f38ac2e9245089545375ebec231ce';

  Future<LocationData?> fetchLocation(double latitude, double longitude) async {
    final response = await http.get(
      Uri.parse('https://api.opencagedata.com/geocode/v1/json?q=$latitude+$longitude&key=$apiKeyGeocoding'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'].isNotEmpty) {
        return LocationData.fromJson(data['results'][0]);
      }
    }
    return null; // If location is not found
  }

  Future<Weather?> fetchWeather(LocationData location) async {
    final response = await http.get(
      Uri.parse('https://api.openweathermap.org/data/2.5/weather?lat=${location.latitude}&lon=${location.longitude}&appid=$apiKeyWeather&units=metric'),
    );

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<LocationData?> fetchLocationFromCityName(String cityName) async {
    final response = await http.get(
      Uri.parse('https://api.opencagedata.com/geocode/v1/json?q=$cityName&key=$apiKeyGeocoding'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'].isNotEmpty) {
        return LocationData.fromJson(data['results'][0]);
      }
    }
    return null; // If location is not found
  }
}
