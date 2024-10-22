import 'package:flutter/material.dart';

class LocationData {
  final String name;
  final double latitude;
  final double longitude;

  LocationData({required this.name, required this.latitude, required this.longitude});

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      name: json['formatted'],
      latitude: json['geometry']['lat'],
      longitude: json['geometry']['lng'],
    );
  }
}
