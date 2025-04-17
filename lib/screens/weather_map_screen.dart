import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import '../services/weather_service.dart';
import '../models/weather_data.dart';

class WeatherMapScreen extends StatefulWidget {
  const WeatherMapScreen({Key? key}) : super(key: key);

  @override
  _WeatherMapScreenState createState() => _WeatherMapScreenState();
}

class _WeatherMapScreenState extends State<WeatherMapScreen> {
  final LocationService _locationService = LocationService();
  final WeatherService _weatherService = WeatherService();
  
  MapController? _mapController;
  WeatherData? _weatherData;
  bool _isLoading = true;
  
  // Coordonnées de Casablanca (valeur par défaut)
  final double _defaultLat = 33.5731;
  final double _defaultLon = -7.5898;

  @override
  void initState() {
    super.initState();
    _initMap();
  }

  Future<void> _initMap() async {
    _mapController = MapController(
      initPosition: GeoPoint(latitude: _defaultLat, longitude: _defaultLon),
    );
    
    Position? position = await _locationService.getCurrentLocation();
    
    double lat = position?.latitude ?? _defaultLat;
    double lon = position?.longitude ?? _defaultLon;
    
    // Pour flutter_osm_plugin 1.3.7
    await _mapController!.goToLocation(GeoPoint(latitude: lat, longitude: lon));
    await _mapController!.setZoom(zoomLevel: 12);
    
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Météo Map'),
      ),
      body: Stack(
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Position? position = await _locationService.getCurrentLocation();
          if (position != null && _mapController != null) {
            await _mapController!.goToLocation(
              GeoPoint(latitude: position.latitude, longitude: position.longitude)
            );
            
            final weatherData = await _weatherService.getWeatherByCoordinates(
              position.latitude, 
              position.longitude
            );
            
            if (weatherData != null) {
              setState(() {
                _weatherData = WeatherData.fromJson(weatherData);
              });
              
              await _addWeatherMarker(position.latitude, position.longitude);
            }
          }
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}