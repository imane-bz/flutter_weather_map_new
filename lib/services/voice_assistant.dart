import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:developer' as developer;

class VoiceAssistant {
  final FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText speech = stt.SpeechToText();
  bool isListening = false;
  bool isInitialized = false;
  
  VoiceAssistant() {
    _initTts();
    _initStt();
  }
  
  Future<void> _initTts() async {
    try {
      await flutterTts.setLanguage("fr-FR");
      await flutterTts.setSpeechRate(0.5);
      await flutterTts.setVolume(1.0);
      await flutterTts.setPitch(1.0);
      developer.log('TTS initialisé avec succès');
    } catch (e) {
      developer.log('Erreur initialisation TTS: $e');
    }
  }
  
  Future<void> _initStt() async {
    try {
      bool available = await speech.initialize(
        onError: (error) => developer.log('Erreur STT: $error'),
      );
      isInitialized = available;
      developer.log('STT disponible: $available');
    } catch (e) {
      developer.log('Erreur initialisation STT: $e');
      isInitialized = false;
    }
  }
  
  Future<void> speak(String text) async {
    try {
      developer.log('TTS parle: $text');
      await flutterTts.speak(text);
    } catch (e) {
      developer.log('Erreur TTS: $e');
    }
  }
  
  Future<bool> startListening(Function(String) onResult) async {
    developer.log('Démarrage de l\'écoute...');
    if (!isInitialized) {
      developer.log('STT non initialisé, tentative de réinitialisation');
      await _initStt();
      if (!isInitialized) {
        developer.log('Échec de l\'initialisation STT');
        return false;
      }
    }
    
    if (!isListening) {
      isListening = true;
      try {
        bool started = await speech.listen(
          onResult: (result) {
            developer.log('STT résultat: ${result.recognizedWords}, final: ${result.finalResult}');
            if (result.finalResult) {
              onResult(result.recognizedWords);
              isListening = false;
            }
          },
          localeId: "fr_FR",
          listenFor: Duration(seconds: 30),
          pauseFor: Duration(seconds: 5),
          listenMode: stt.ListenMode.dictation, // Mode dictation est plus fiable
          cancelOnError: false,
        );
        developer.log('Écoute démarrée: $started');
        return started;
      } catch (e) {
        developer.log('Erreur lors du démarrage de l\'écoute: $e');
        isListening = false;
        return false;
      }
    }
    return false;
  }
  
  Future<void> stopListening() async {
    developer.log('Arrêt de l\'écoute');
    await speech.stop();
    isListening = false;
  }
  
  void dispose() {
    flutterTts.stop();
    speech.stop();
    developer.log('VoiceAssistant dispose');
  }
}