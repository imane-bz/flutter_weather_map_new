import 'package:flutter/material.dart';
import 'screens/weather_map_screen.dart';  // Importez votre écran de météo

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Météo Map',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const WeatherMapScreen(),  // Utilisez l'écran de météo comme écran principal
    );
  }
}