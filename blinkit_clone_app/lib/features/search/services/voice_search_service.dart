// lib/features/search/services/voice_search_service.dart
// Android native speech recognition engine wrapper (zero-cost, on-device OS service)
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceSearchService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;

  bool get isListening => _speech.isListening;

  Future<bool> initialize({void Function(String status)? onStatus}) async {
    if (_isInitialized) return true;
    try {
      _isInitialized = await _speech.initialize(
        onStatus: (status) {
          debugPrint('[VoiceSearch] status: $status');
          onStatus?.call(status);
        },
        onError: (error) => debugPrint('[VoiceSearch] error: ${error.errorMsg}'),
      );
      return _isInitialized;
    } catch (e) {
      debugPrint('[VoiceSearch] Speech initialization exception: $e');
      return false;
    }
  }

  Future<void> startListening({
    required void Function(String text, bool isFinal) onResult,
    void Function(double level)? onSoundLevelChange,
    VoidCallback? onListeningStopped,
  }) async {
    final available = await initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening' || status == 'doneListening') {
          onListeningStopped?.call();
        }
      },
    );
    if (!available) {
      debugPrint('[VoiceSearch] Speech recognition unavailable on this device');
      onListeningStopped?.call();
      return;
    }

    try {
      await _speech.listen(
        listenOptions: stt.SpeechListenOptions(
          localeId: 'en_IN', // English (India) as shown in reference Image 4
          partialResults: true, // Stream live words in real time as the user speaks
          cancelOnError: true,
          listenMode: stt.ListenMode.search,
        ),
        onResult: (result) {
          final words = result.recognizedWords.trim();
          if (words.isNotEmpty) {
            onResult(words, result.finalResult);
          }
        },
        onSoundLevelChange: onSoundLevelChange,
      );
    } catch (e) {
      debugPrint('[VoiceSearch] Error starting listen: $e');
      onListeningStopped?.call();
    }
  }

  Future<void> stopListening() async {
    try {
      if (_speech.isListening) {
        await _speech.stop();
      }
    } catch (e) {
      debugPrint('[VoiceSearch] Error stopping listen: $e');
    }
  }
}
