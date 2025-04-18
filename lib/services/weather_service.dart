import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  // Remplacez par votre clé API OpenWeatherMap réelle
  final String apiKey = '5f3461d0437e45c37c12d8eb3c55c7e6';
  
  // Client HTTP qui ignore les erreurs de certificat - partagé entre méthodes
  HttpClient _createSecureClient() {
    return HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }

  Future<dynamic> getWeatherByCoordinates(double lat, double lon) async {
    try {
      final client = _createSecureClient();
      final url = 'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&appid=$apiKey';
      
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      
      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        return jsonDecode(responseBody);
      } else {
        print("Erreur API météo: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Exception lors de l'appel API météo: $e");
      return null;
    }
  }
  
  Future<Map<String, dynamic>?> getWeatherByCity(String city) async {
    try {
      // Utiliser le même client sécurisé pour les deux méthodes
      final client = _createSecureClient();
      final url = 'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';
      
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      
      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        return jsonDecode(responseBody);
      } else {
        print("Erreur API météo: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Exception lors de l'appel API météo: $e");
      return null;
    }
  }
}