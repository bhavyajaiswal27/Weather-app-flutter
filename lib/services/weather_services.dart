import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherServices {
  final String apiKey = '83ded275803c44298b6163450241406';
  final String forecastUrl = 'https://api.weatherapi.com/v1/forecast.json';
  final String searchUrl = 'https://api.weatherapi.com/v1/search.json';

  Future<Map<String, dynamic>> fetchCurrentWeather(String city) async {
    final url = '$forecastUrl?key=$apiKey&q=$city&days=1&aqi=no&alerts=no';
    print('Fetching URL: $url'); // Debugging statement
    final response = await http.get(Uri.parse(url));
    print('Response status: ${response.statusCode}'); // Debugging statement
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print('Response body: ${response.body}'); // Debugging statement
      throw Exception('Failed to load');
    }
  }

  Future<Map<String, dynamic>> fetch7dayWeather(String city) async {
    final url = '$forecastUrl?key=$apiKey&q=$city&days=7&aqi=no&alerts=no';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load 7 day forecast');
    }
  }

  Future<List<dynamic>?> suggestCities(String query) async {
    final url = '$searchUrl?key=$apiKey&q=$query';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }
}
