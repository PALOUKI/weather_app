import 'package:flutter/material.dart';
import 'package:location/location.dart';
import '../../services/weather_service.dart';
import '../models/location_data.dart';
import '../models/weather.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {


  Weather? weather;
  final TextEditingController _controller = TextEditingController();
  final WeatherService _weatherService = WeatherService();

  @override
  void initState() {
    super.initState();
    _getCurrentLocationWeather(); // Fetch weather on startup
  }

  Future<void> _getCurrentLocationWeather() async {
    Location location = Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    // Check if the location service is enabled
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    // Check if permission is granted
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    // Get current location/******/
    final locationData = await location.getLocation().then((loc) {
      return _weatherService.fetchLocation(loc.latitude!, loc.longitude!);
    });

    if (locationData != null) {
      _weatherService.fetchWeather(locationData).then((value) {
        setState(() {
          weather = value;
        });
      }).catchError((error) {
        print('Error: $error');
        setState(() {
          weather = null; // Reset data in case of error
        });
      });
    }
  }

  void _getWeather() async {
    String cityName = _controller.text;/***********/

    final location = await _weatherService.fetchLocationFromCityName(cityName);

    if (location != null) {
      _weatherService.fetchWeather(location).then((value) {
        setState(() {
          weather = value;
        });
      }).catchError((error) {
        print('Error: $error');
        setState(() {
          weather = null; // Reset data in case of error
        });
      });
    } else {
      print('Location not found.');
      setState(() {
        weather = null; // Reset data if location is not found
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Image.asset("assets/icons/rain_icon.png", width: 60, fit: BoxFit.cover,),
                  const Text("CLOUDY",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFFF5F5F5),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20,),
               Text("${weather?.temperature}°C",
                style: TextStyle(
                  fontSize: 110,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF5F5F5),
                ),
              ),

            ],
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.arrow_upward, color: Colors.white),
              Text("22°c",
              style: TextStyle(
                fontSize: 22,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
              ),
              ),
              Icon(Icons.arrow_downward, color: Colors.white),
              Text("14°c",
                style: TextStyle(
                  fontSize: 22,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 10,)
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  Image.asset("assets/icons/sunrise.png", width: 35,),
                  const SizedBox(width: 5,),
                  const Column(
                    children: [
                      Text("Sunrise",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.orangeAccent,
                        ),
                      ),
                      Text("14:00 AM")
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  Image.asset("assets/icons/sunset.png", width: 35,),
                  const SizedBox(width: 5,),
                  const Column(
                    children: [
                      Text("Sunset",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.orangeAccent,
                        ),
                      ),
                      Text("5:00 PM")
                    ],
                  ),
                ],
              ),
            ],
          ),
          const Card(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            elevation: 15,
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 40),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text("Humidity",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.italic,
                            fontSize: 16,
                          ),),
                          Text("value")
                        ],
                      ),
                      Column(
                        children: [
                          Text("visibility",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.italic,
                              fontSize: 16,
                            ),),
                          Text("value")
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text("Presure",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.italic,
                              fontSize: 16,
                            ),),
                          Text("value")
                        ],
                      ),
                      Column(
                        children: [
                          Text("Windspeed",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.italic,
                              fontSize: 16,
                            ),),
                          Text("value")
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      )
    );
  }
}
