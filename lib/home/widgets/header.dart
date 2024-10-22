import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import '../../services/weather_service.dart';
import '../models/weather.dart';

class HeaderSection extends StatefulWidget {
  const HeaderSection({super.key});

  @override
  State<HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<HeaderSection> {
  Weather? weather;
  final TextEditingController _controller = TextEditingController();
  final WeatherService _weatherService = WeatherService();
  bool isLoading = false; // Indicateur de chargement
  String cityName = "New York"; // Nom de la ville par défaut

  @override
  void initState() {
    super.initState();
    _getCurrentLocationWeather(); // Récupérer la météo au démarra
  }

  Future<void> _getCurrentLocationWeather() async {
    setState(() {
      isLoading = true; // Démarrer le chargement
    });
    Location location = Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    // Vérifier si le service de localisation est activé
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        setState(() {
          isLoading = false; // Arrêter le chargement
        });
        return;
      }
    }

    // Vérifier si l'autorisation est accordée
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        setState(() {
          isLoading = false; // Arrêter le chargement
        });
        return;
      }
    }

    // Obtenir la localisation actuelle
    final locationData = await location.getLocation();
    final locationInfo = await _weatherService.fetchLocation(locationData.latitude!, locationData.longitude!);

    if (locationInfo != null) {
      final weatherData = await _weatherService.fetchWeather(locationInfo);
      setState(() {
        weather = weatherData;
        cityName = locationInfo.name; // Mettre à jour le nom de la ville
        isLoading = false; // Arrêter le chargement
      });
    } else {
      setState(() {
        weather = null;
        isLoading = false; // Arrêter le chargement
      });
    }
  }

  void _getWeather() async {
    setState(() {
      isLoading = true; // Démarrer le chargement
    });

    String inputCityName = _controller.text;
    final location = await _weatherService.fetchLocationFromCityName(inputCityName);

    if (location != null) {
      final weatherData = await _weatherService.fetchWeather(location);
      setState(() {
        weather = weatherData;
        cityName = inputCityName; // Mettre à jour le nom de la ville
        isLoading = false; // Arrêter le chargement
      });
    } else {
      setState(() {
        weather = null; // Réinitialiser les données si la localisation n'est pas trouvée
        isLoading = false; // Arrêter le chargement
      });
      print('Localisation non trouvée.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = DateTime.now();
    final formatter = DateFormat('EEE, MMM d');
    final formattedDate = formatter.format(date);
    final timeFormatter = DateFormat('hh:mm a');
    final formattedTime = timeFormatter.format(date);

    return Container(
      padding: EdgeInsets.all(15),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Icon(Icons.location_pin, size: 50, color: Colors.orangeAccent),
                SizedBox(width: 10),
                Text(
                  cityName,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 50,
                    color: Colors.orangeAccent,
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              formattedDate,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 25,
                color: Colors.white,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              formattedTime,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 25,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 35),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: "Entrez le nom de la ville",
              hintStyle: TextStyle(
                color: Colors.black45,
              ),
              filled: true,
              fillColor: Colors.grey.withOpacity(0.5),
              suffixIcon: const Icon(Icons.search_rounded, size: 30, color: Colors.white),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue, width: 2.0),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.orangeAccent, width: 2.0),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _getWeather,
            child: Text('Obtenir la météo'),
          ),
          if (isLoading) // Afficher un indicateur de chargement
            CircularProgressIndicator(),
          if (weather != null) // Afficher les données météo
            Text("Température: ${weather!.temperature}°C"),
        ],
      ),
    );
  }
}
