import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import '../services/weather_service.dart';
import '../services/voice_assistant.dart';
import '../models/weather_data.dart';

class WeatherMapScreen extends StatefulWidget {
  const WeatherMapScreen({Key? key}) : super(key: key);

  @override
  _WeatherMapScreenState createState() => _WeatherMapScreenState();
}

class _WeatherMapScreenState extends State<WeatherMapScreen> {
  final LocationService _locationService = LocationService();
  final WeatherService _weatherService = WeatherService();
  late VoiceAssistant _voiceAssistant;
  
  MapController? _mapController;
  WeatherData? _weatherData;
  bool _isLoading = true;
  bool _isListening = false;
  
  // Coordonnées de Casablanca (valeur par défaut)
  final double _defaultLat = 33.5731;
  final double _defaultLon = -7.5898;

  @override
  void initState() {
    super.initState();
    _voiceAssistant = VoiceAssistant();
    _initMap();
  }

  Future<void> _initMap() async {
    _mapController = MapController(
      initPosition: GeoPoint(latitude: _defaultLat, longitude: _defaultLon),
    );
    
    Position? position = await _locationService.getCurrentLocation();
    
    double lat = position?.latitude ?? _defaultLat;
    double lon = position?.longitude ?? _defaultLon;
    
    try {
      await _mapController!.goToLocation(GeoPoint(latitude: lat, longitude: lon));
      await _mapController!.setZoom(zoomLevel: 12);
    } catch (e) {
      // Méthode alternative si la première échoue
      print("Navigation error: $e");
    }
    
    // Obtenir les données météo
    final weatherData = await _weatherService.getWeatherByCoordinates(lat, lon);
    
    if (weatherData != null) {
      setState(() {
        _weatherData = WeatherData.fromJson(weatherData);
        _isLoading = false;
      });
      
      // Ajouter un marqueur pour la météo
      await _addWeatherMarker(lat, lon);
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addWeatherMarker(double lat, double lon) async {
    if (_weatherData == null || _mapController == null) return;
    
    // Version pour flutter_osm_plugin 1.3.7
    try {
      await _mapController!.addMarker(
        GeoPoint(latitude: lat, longitude: lon),
        markerIcon: MarkerIcon(
          icon: Icon(
            Icons.cloud,
            color: Colors.blue,
            size: 48,
          ),
        ),
      );
    } catch (e) {
      print("Error adding marker: $e");
    }
  }
  
  void _handleVoiceCommand(String text) {
    text = text.toLowerCase();
    if (text.contains('météo') || text.contains('temps')) {
      _speakWeatherInfo();
    } else if (text.contains('localisation') || text.contains('position')) {
      _goToCurrentLocation();
    } else if (text.contains('aide') || text.contains('commandes')) {
      _voiceAssistant.speak("Vous pouvez demander la météo, votre localisation ou de l'aide");
    }
  }
  
  void _speakWeatherInfo() {
    if (_weatherData != null) {
      String weatherText = "À ${_weatherData!.cityName}, il fait ${_weatherData!.temperature.toStringAsFixed(1)} degrés, avec ${_weatherData!.description}. L'humidité est de ${_weatherData!.humidity} pourcent et le vent souffle à ${_weatherData!.windSpeed} mètres par seconde.";
      _voiceAssistant.speak(weatherText);
    } else {
      _voiceAssistant.speak("Je n'ai pas d'informations météo disponibles");
    }
  }
  
  void _goToCurrentLocation() async {
    Position? position = await _locationService.getCurrentLocation();
    if (position != null && _mapController != null) {
      try {
        await _mapController!.goToLocation(
          GeoPoint(latitude: position.latitude, longitude: position.longitude)
        );
        _voiceAssistant.speak("Je vous ai localisé sur la carte");
      } catch (e) {
        print("Error navigating to location: $e");
        _voiceAssistant.speak("Problème lors de la navigation sur la carte");
      }
    } else {
      _voiceAssistant.speak("Impossible de vous localiser");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RouteGenie'),
        actions: [], 
      ),
      
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'RouteGenie',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('Carte'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Ma position'),
              onTap: () {
                _goToCurrentLocation();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.mic),
              title: const Text('Assistant vocal'),
              onTap: () {
                setState(() {
                  _isListening = true;
                });
                _voiceAssistant.speak("Comment puis-je vous aider?");
                _voiceAssistant.startListening(_handleVoiceCommand);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('À propos'),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'RouteGenie',
                  applicationVersion: '1.0.0',
                  children: [
                    const Text('Une application de météo et cartographie développée avec Flutter'),
                  ],
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      
      body: Column(
        children: [
          // La carte principale (prend la majorité de l'espace)
          Expanded(
            child: Stack(
              children: [
                _mapController == null 
                  ? const Center(child: CircularProgressIndicator())
                  : OSMFlutter(
                      controller: _mapController!,
                      osmOption: OSMOption(
                        userTrackingOption: UserTrackingOption(
                          enableTracking: false,
                          unFollowUser: true,
                        ),
                        zoomOption: ZoomOption(
                          initZoom: 12,
                          minZoomLevel: 4,
                          maxZoomLevel: 19,
                          stepZoom: 1.0,
                        ),
                        roadConfiguration: RoadOption(
                          roadColor: Colors.blueAccent,
                        ),
                      ),
                    ),
                
                if (_weatherData != null)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _weatherData!.cityName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Image.network(
                                  'https://openweathermap.org/img/wn/${_weatherData!.icon}@2x.png',
                                  width: 50,
                                  height: 50,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${_weatherData!.temperature.toStringAsFixed(1)}°C',
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ],
                            ),
                            Text(
                              'Description: ${_weatherData!.description}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Humidité: ${_weatherData!.humidity}%',
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Vent: ${_weatherData!.windSpeed} m/s',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                
                if (_isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),
          
          // Bouton microphone juste avant le footer
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isListening = !_isListening;
                  });
                  if (_isListening) {
                    _voiceAssistant.startListening(_handleVoiceCommand);
                  } else {
                    _voiceAssistant.stopListening();
                  }
                },
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: _isListening ? Colors.red.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: _isListening ? Colors.red : Colors.blue,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
          
          // Footer Capgemini modifié
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            color: const Color.fromARGB(255, 109, 134, 163),
            width: double.infinity,
            child: Center(
              child: Builder(
                builder: (context) {
                  try {
                    // Logo plus grand et centré
                    return Image.asset(
                      'assets/images/capgemini_logo.png', 
                      height: 35,  // Taille augmentée
                      fit: BoxFit.contain,
                    );
                  } catch (e) {
                    return const Icon(
                      Icons.business, 
                      color: Colors.white, 
                      size: 35,
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: _goToCurrentLocation,
        child: const Icon(Icons.my_location),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _voiceAssistant.dispose();
    super.dispose();
  }
}