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
      debugShowCheckedModeBanner: false,  // Ajoutez cette ligne pour supprimer la bannière DEBUG
      title: 'RouteGenie',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const WeatherMapScreen(),
    );
  }
}