import 'package:flutter_tts/flutter_tts.dart';
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