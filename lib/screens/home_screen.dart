import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_app/screens/forecast_screen.dart';
import 'package:weather_app/services/weather_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherServices _weatherServices = WeatherServices();
  String city = "London";
  Map<String, dynamic>? _currentWeather;

  @override
  void initState() {
    super.initState();
    _fetchWeather(city);
  }

  Future<void> _fetchWeather(city) async {
    try {
      // print('Fetching weather data for $city...'); // Debugging statement
      final weatherData = await _weatherServices.fetchCurrentWeather(city);
      // print('Weather data fetched: $weatherData'); // Debugging statement
      setState(() {
        _currentWeather = weatherData;
      });
    } catch (e) {
      // print('Error fetching weather data: $e'); // Debugging statement
    }
  }

  void _showCitySelectDialog() {
    showDialog(context: context, builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Enter City name"),
        content: TypeAheadField(
          suggestionsCallback: (pattern)async {
            return await _weatherServices.suggestCities(pattern);
          },
          builder: (context, controller, focusNode) {
            return TextField(
            controller: controller,
            focusNode: focusNode,
            autofocus: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(

              ),
              labelText: "City",
            ),
            
            );
            
          },
          itemBuilder: (context, suggestion) {
            return ListTile(title: Text(suggestion['name']),);
          },
          onSelected: (city){
            setState(() {
              city = city['name'];
            });
          },
          ),
          actions: [
            TextButton(onPressed: (){
              Navigator.pop(context);
            }, child: const Text("Cancel")),
            TextButton(onPressed: () {
              Navigator.pop(context);
              _fetchWeather(city);
            }, child: const Text("Submit"))
          ],
      );
    });
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
      // print('Icon URL: $iconUrl'); // Debugging statement
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
          : SingleChildScrollView( // Wrap content in SingleChildScrollView
              child: Container(
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
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: _showCitySelectDialog,
                      child: Text(
                        city,
                        style: GoogleFonts.lato(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    if (iconUrl != null) Image.network(
                      iconUrl,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
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
                    Text('${_currentWeather!['current']['temp_c'].round()}C', style: GoogleFonts.lato(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    ),
                    Text('${_currentWeather!['current']['condition']['text']}', style: GoogleFonts.lato(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    )
                    ),
                    const SizedBox(height: 5,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          'Max: ${_currentWeather!['forecast']['forecastday'][0]['day']['maxtemp_c'].round()}C',
                          style: GoogleFonts.lato(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white60,
                          ),
                        ),
                        Text(
                          'Min: ${_currentWeather!['forecast']['forecastday'][0]['day']['mintemp_c'].round()}C',
                          style: GoogleFonts.lato(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 35,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildWeatherDetails('Sunrise', Icons.wb_sunny,
                          _currentWeather!['forecast']['forecastday'][0]['astro']['sunrise']
                        ),
                        _buildWeatherDetails('Sunset', Icons.brightness_3,
                          _currentWeather!['forecast']['forecastday'][0]['astro']['sunset']
                        ),
                      ],
                    ),
                    const SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildWeatherDetails('Humidity', Icons.opacity,
                          _currentWeather!['current']['humidity']
                        ),
                        _buildWeatherDetails('Wind (KMPH)', Icons.wind_power,
                          _currentWeather!['current']['wind_kph']
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ForecastScreen(city: city,)));
                        },
                        child: const Text("Next 7 days weather"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildWeatherDetails(String label, IconData icon, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: Container(
            padding: const EdgeInsets.all(5),
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
                colors: [
                  const Color(0xFF1A2344).withOpacity(0.5),
                  const Color(0xFF1A2344).withOpacity(0.2),
                ]
              )
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white,),
                const SizedBox(height: 8,),
                Text(label,
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white60,
                  ),
                ),
                const SizedBox(height: 8,),
                Text(value is String ? value : value.toString(),
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
