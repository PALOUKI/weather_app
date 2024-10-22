import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import '../../services/weather_service.dart';
import 'models/weather.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  Weather? weather;
  final TextEditingController _controller = TextEditingController();
  final WeatherService _weatherService = WeatherService();
  String cityName = "Meteo";
  String bgImage = "assets/images/clear.jpg";
  String weatherIcon = "assets/icons/fog-icon.png";
  String? errorMessage; // To print erros messages

  @override
  void initState() {
    super.initState();
    _getCurrentLocationWeather(); // get weather on load
  }

  Future<void> _getCurrentLocationWeather() async {
    Location location = Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    // to verify if weather services are disponible
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) return;
    }

    // // to verify if weather services are allowed
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) return;
    }

    // To get actually location
    final locationData = await location.getLocation();
    final locationInfo = await _weatherService.fetchLocation(locationData.latitude!, locationData.longitude!);

    if (locationInfo != null) {
      final weatherData = await _weatherService.fetchWeather(locationInfo);
      if (weatherData != null) {
        setState(() {
          weather = weatherData;
          cityName = locationInfo.name; // get city name Ontime
          errorMessage = null; // to reset error message
        });
      } else {
        setState(() {
          errorMessage = "Erreur lors de la récupération des données météo.";
        });
      }
    } else {
      setState(() {
        errorMessage = "Localisation non trouvée.";
      });
    }
  }

  void _getWeather() async {
    print("ok, i will going to get weather");
    String inputCityName = _controller.text;
    final location = await _weatherService.fetchLocationFromCityName(inputCityName);

    if (location != null) {
      final weatherData = await _weatherService.fetchWeather(location);
      if (weatherData != null) {
        setState(() {
          weather = weatherData;
          cityName = inputCityName; // get Ontime city name
          errorMessage = null; // reset error message

          _updateBackgroundImageAndWeatherIcon();
        });
      } else {
        setState(() {
          errorMessage = "Erreur lors de la récupération des données météo.";
        });
      }
    } else {
      setState(() {
        weather = null; // reset data if location data are not get
        errorMessage = "Localisation non trouvée.";
      });
    }
  }

  void _updateBackgroundImageAndWeatherIcon() {
    if (weather?.description.contains("clouds") == true) {
      bgImage = 'assets/images/clouds.jpg';
      weatherIcon = 'assets/icons/clouds_icon.png';
    } else if (weather?.description.contains("rain") == true) {
      bgImage = 'assets/images/rain.jpeg';
      weatherIcon = 'assets/icons/rain_icon.png';
    } else if (weather?.description.contains("fog") == true) {
      bgImage = 'assets/images/fog.jpeg';
      weatherIcon = 'assets/icons/fog-icon.png';
    } else if (weather?.description.contains("thunderstorm") == true) {
      bgImage = 'assets/images/thunderstorm.jpeg';
      weatherIcon = 'assets/icons/thunderstorm_icon.png';
    } else if (weather?.description.contains("clear") == true) {
      bgImage = 'assets/images/clear.jpg';
      weatherIcon = 'assets/icons/clear_icon.png';
    }
    else
    {
      bgImage = 'assets/images/clouds.jpg';
      weatherIcon = 'assets/icons/clouds_icon.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = DateTime.now();
    final formatter = DateFormat('EEE, MMM d');
    final formattedDate = formatter.format(date);
    final timeFormatter = DateFormat('hh:mm a');
    final formattedTime = timeFormatter.format(date);

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            bgImage,
            fit: BoxFit.cover,
          ),
        ),
        Container(
          padding: const EdgeInsets.all(15),
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 18,),
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    const Icon(Icons.location_pin, size: 50, color: Colors.orangeAccent),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        cityName[0].toUpperCase() + cityName.substring(1).toLowerCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 50,
                          color: Colors.orangeAccent,
                          fontStyle: FontStyle.italic,
                        ),
                        softWrap: true,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                    fontWeight: FontWeight.w500,
                    fontSize: 28,
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  formattedTime,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 28,
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 35),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: "Entrez le nom de la ville",
                  hintStyle: const TextStyle(color: Colors.black45),
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.5),
                  suffixIcon: GestureDetector(
                    onTap: _getWeather,
                    child: Icon(Icons.search_rounded, size: 30, color: Colors.white),
                  ),
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
              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 18),
                  ),
                ),
              if (weather != null)
                WeatherInfo(weather: weather, weatherIcon: weatherIcon), // Passer weatherIcon icon
            ],
          ),
        ),
      ],
    );
  }
}
class WeatherInfo extends StatelessWidget {
  final Weather? weather;
  final String weatherIcon;

  const WeatherInfo({super.key, required this.weather, required this.weatherIcon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Image.asset(weatherIcon, width: 60, fit: BoxFit.cover),
                Text(
                  (weather!.description.split(" ").length > 1)
                      ? "${weather?.description.split(" ")[1]}"
                      : "thunderstorm",
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFF5F5F5),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Text("${weather?.temperature.round()}°",
              style: const TextStyle(
                fontSize: 110,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF5F5F5),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Icon(Icons.arrow_upward, color: Colors.white,),
            Text(
              "${weather?.tempMax.toStringAsFixed(1) ?? 'N/A'}°c",
              style: const TextStyle(
                fontSize: 22,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            const Icon(Icons.arrow_downward, color: Colors.white),
            Text("${weather?.tempMin.toStringAsFixed(1) ?? 'N/A'}°c",
              style: const TextStyle(
                fontSize: 22,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 10)
          ],
        ),
        Center(
          child: Text("${weather?.description}",
            style: const TextStyle(
              fontSize: 28,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              children: [
                Image.asset("assets/icons/sunrise.png", width: 35),
                const SizedBox(width: 5),
                Column(
                  children: [
                    const Text("Lever de soleil",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.orangeAccent,
                      ),
                    ),
                    Text("${weather?.sunrise}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                Image.asset("assets/icons/sunset.png", width: 35),
                const SizedBox(width: 5),
                Column(
                  children: [
                    const Text("Coucher de soleil",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.orangeAccent,
                      ),
                    ),
                    Text("${weather?.sunset}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                    ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        Card(
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
                        Image.asset("assets/icons/humidity-icon.png", width: 40,),
                        const Text("Humidité",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.italic,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 5,),
                        Text("${weather?.humidity}") // Remplace par la valeur d'humidité
                      ],
                    ),
                    Column(
                      children: [
                        Image.asset("assets/icons/visibility-icon.png", width: 40,),
                        const Text("Visibilité",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.italic,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 5,),
                        Text("${weather?.visibility}") // Remplace par la valeur de visibilité
                      ],
                    ),
                    Column(
                      children: [
                        Image.asset("assets/icons/pressure-icon.webp", width: 40,),
                        const Text("Pression",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.italic,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 5,),
                        Text("${weather?.pressure}") // Remplace par la valeur de pression
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
