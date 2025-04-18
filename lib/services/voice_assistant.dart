import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
// Removed unused import
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceAssistant {
  final FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText speech = stt.SpeechToText();
  bool isListening = false;
  
  VoiceAssistant() {
    _initTts();
    _initStt();
  }
  
  Future<void> _initTts() async {
    await flutterTts.setLanguage("fr-FR");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
  }
  
  Future<void> _initStt() async {
    await speech.initialize();
  }
  
  Future<void> speak(String text) async {
    await flutterTts.speak(text);
  }
  
  Future<void> startListening(Function(String) onResult) async {
    if (!isListening) {
      isListening = true;
      await speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            onResult(result.recognizedWords);
            isListening = false;
          }
        },
        localeId: "fr_FR",
        listenFor: Duration(seconds: 30),
        pauseFor: Duration(seconds: 5),
        // ignore: deprecated_member_use
        listenMode: stt.ListenMode.confirmation,
        cancelOnError: false,
      );
    }
  }
  
  Future<void> stopListening() async {
    await speech.stop();
    isListening = false;
  }
  
  void dispose() {
    flutterTts.stop();
    speech.stop();
  }
}

class WeatherMapScreen extends StatefulWidget {
  @override
  _WeatherMapScreenState createState() => _WeatherMapScreenState();
}

class _WeatherMapScreenState extends State<WeatherMapScreen> {
  bool _isListening = false;
  final VoiceAssistant _voiceAssistant = VoiceAssistant();

  void _handleVoiceCommand(String command) {
    // Handle the voice command here
    print("Recognized command: $command");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
      title: const Text('Météo Map'),
      // Retirez le bouton micro d'ici si présent
    ),
    
    drawer: Drawer(
      // Votre code de drawer existant
    ),
    
    body: Column(
      children: [
        // La carte principale (prend la majorité de l'espace)
        Expanded(
          child: Stack(
            children: [
              // Votre code OSM et carte météo existant
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
                  color: _isListening ? Colors.red.withOpacity(0.2) : Colors.blue[800],
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
        ),
        
        // Footer Capgemini
        Container(
          // Votre code de footer existant
        ),
      ],
    ),
  );
  }
}
