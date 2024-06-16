import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_app/services/weather_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherServices _weatherServices = WeatherServices();
  String city = "Sirsa";
  Map<String, dynamic>? _currentWeather;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    try {
      print('Fetching weather data for $city...'); // Debugging statement
      final weatherData = await _weatherServices.fetchCurrentWeather(city);
      print('Weather data fetched: $weatherData'); // Debugging statement
      setState(() {
        _currentWeather = weatherData;
      });
    } catch (e) {
      print('Error fetching weather data: $e'); // Debugging statement
    }
  }

  @override
  Widget build(BuildContext context) {
    String? iconUrl;
    if (_currentWeather != null) {
      String iconPath = _currentWeather!['current']['condition']['icon'];
      // Ensure the iconPath is correctly prefixed with https:
      if (iconPath.startsWith("//")) {
        iconPath = "https:$iconPath";
      }
      iconUrl = iconPath;
      print('Icon URL: $iconUrl'); // Debugging statement
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
      ),
      body: _currentWeather == null
          ? Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF1A2344),
                    Color.fromARGB(255, 125, 32, 142),
                    Colors.purple,
                    Color.fromARGB(255, 151, 44, 170),
                  ],
                ),
              ),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            )
          : Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF1A2344),
                    Color.fromARGB(255, 125, 32, 142),
                    Colors.purple,
                    Color.fromARGB(255, 151, 44, 170),
                  ],
                ),
              ),
              child: ListView(
                children: [
                  const SizedBox(height: 10),
                  Text(
                    city,
                    style: GoogleFonts.lato(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Column(
                      children: [
                        if (iconUrl != null) Image.network(
                          iconUrl,
                          height: 100,
                          width: 100,
                          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                            return const Text(
                              'Error loading image',
                              style: TextStyle(color: Colors.red),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
