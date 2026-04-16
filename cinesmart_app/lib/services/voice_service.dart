import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';

class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  late stt.SpeechToText _speechToText;
  late FlutterTts _flutterTts;

  bool _isListening = false;
  String _lastWords = '';
  StreamController<String>? _recognitionController;
  StreamController<bool>? _listeningController;

  factory VoiceService() {
    return _instance;
  }

  VoiceService._internal() {
    _speechToText = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _initializeTts();
  }

  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  /// Initialize speech recognition
  Future<bool> initialize() async {
    try {
      final available = await _speechToText.initialize(
        onError: (error) => print('Error: $error'),
        onStatus: (status) => print('Status: $status'),
      );
      return available;
    } catch (e) {
      print('Failed to initialize speech recognition: $e');
      return false;
    }
  }

  /// Start listening for speech
  void startListening({
    required Function(String) onResult,
    required Function(bool) onListeningChanged,
  }) {
    if (!_isListening) {
      _isListening = true;
      onListeningChanged(true);

      _speechToText.listen(
        onResult: (result) {
          _lastWords = result.recognizedWords;
          onResult(_lastWords);
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 5),
        partialResults: true,
        localeId: 'en_US',
      );
    }
  }

  /// Stop listening
  void stopListening() {
    if (_isListening) {
      _speechToText.stop();
      _isListening = false;
    }
  }

  /// Speak text using text-to-speech
  Future<void> speak(String text) async {
    if (text.isNotEmpty) {
      await _flutterTts.speak(text);
    }
  }

  /// Stop speaking
  Future<void> stopSpeaking() async {
    await _flutterTts.stop();
  }

  /// Get availability status
  bool get isAvailable => _speechToText.isAvailable;
  bool get isListening => _isListening;
  String get lastWords => _lastWords;

  /// Dispose resources
  void dispose() {
    _recognitionController?.close();
    _listeningController?.close();
  }
}
