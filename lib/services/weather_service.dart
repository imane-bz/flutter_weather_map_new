import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  // Votre clé API
  final String apiKey = "928fe5d03d1a7abd2935cb673b55044f";
  
  Future<Map<String, dynamic>?> getWeatherByCoordinates(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric')
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Erreur: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception lors de la récupération de la météo: $e');
      return null;
    }
  }
  
  Future<Map<String, dynamic>?> getWeatherByCity(String city) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric')
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Erreur: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception lors de la récupération de la météo: $e');
      return null;
    }
  }
}