/*import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  DateTime? _lastWordTime;

  bool get isListening => _isListening;

  Future<void> startListening(
    Function(String, bool, bool) onTextRecognized,
  ) async {
    bool available = await _speech.initialize(
      onStatus: (status) => _isListening = status == "listening",
      onError: (error) => print("Speech recognition error: $error"),
    );

    if (available) {
      _isListening = true;
      _speech.listen(
        onResult: (result) {
          String text = result.recognizedWords;
          bool hasStutter = detectStuttering(text);
          bool hasPause = detectPauses();

          onTextRecognized(text, hasStutter, hasPause);
        },
      );
    } else {
      print("Speech recognition not available");
    }
  }

  void stopListening() {
    _speech.stop();
    _isListening = false;
  }

  // ✅ Detect if there's a long pause between words
  bool detectPauses() {
    DateTime now = DateTime.now();
    if (_lastWordTime == null) {
      _lastWordTime = now;
      return false; // First word, no pause detected
    }

    Duration timeDiff = now.difference(_lastWordTime!);
    _lastWordTime = now; // Update the last word time

    return timeDiff.inMilliseconds > 1500; // 1.5 seconds pause detected
  }

  // ✅ Detect stuttering (e.g., "th-th-the", "b-b-banana")
  bool detectStuttering(String text) {
    List<String> words = text.split(" ");

    for (String word in words) {
      // Detect patterns like "b-b-ball" or "th-th-the"
      RegExp complexStutterPattern = RegExp(
        r"\b(\w{1,3})-\1\w*\b|\b(\w+)\s+\2\b",
      );

      // Detect repeated letters (e.g., "sssssnake", "baaaall")
      RegExp prolongationPattern = RegExp(r"\b([a-zA-Z])\1{2,}");

      if (complexStutterPattern.hasMatch(word) ||
          prolongationPattern.hasMatch(word)) {
        return true;
      }
    }
    return false;
  }
}
*/
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  DateTime? _lastWordTime;

  bool get isListening => _isListening;

  Future<void> startListening(
    Function(String, bool, bool) onTextRecognized,
  ) async {
    bool available = await _speech.initialize(
      onStatus: (status) => _isListening = status == "listening",
      onError: (error) => print("Speech recognition error: $error"),
    );

    if (available) {
      _isListening = true;
      _speech.listen(
        onResult: (result) {
          String text = result.recognizedWords;
          bool hasStutter = detectStuttering(text);
          bool hasPause = detectPauses();

          onTextRecognized(text, hasStutter, hasPause);
        },
        listenFor: Duration(seconds: 10), // Adjust as needed
        pauseFor: Duration(seconds: 2),
        partialResults: true,
        localeId: "en_US", // Change based on language preference
      );
    } else {
      print("Speech recognition not available");
    }
  }

  void stopListening() {
    _speech.stop();
    _isListening = false;
  }

  void cancelListening() {
    _speech.cancel();
    _isListening = false;
  }

  // ✅ Detect if there's a long pause between words
  bool detectPauses() {
    DateTime now = DateTime.now();
    if (_lastWordTime == null) {
      _lastWordTime = now;
      return false; // First word, no pause detected
    }

    Duration timeDiff = now.difference(_lastWordTime!);
    _lastWordTime = now; // Update the last word time

    return timeDiff.inMilliseconds > 1500; // 1.5 seconds pause detected
  }

  // ✅ Detect stuttering (e.g., "th-th-the", "b-b-banana")
  bool detectStuttering(String text) {
    List<String> words = text.split(" ");

    for (String word in words) {
      // Detect patterns like "b-b-ball" or "th-th-the"
      RegExp complexStutterPattern = RegExp(
        r"\b(\w{1,3})-\1\w*\b|\b(\w+)\s+\2\b",
      );

      // Detect repeated letters (e.g., "sssssnake", "baaaall")
      RegExp prolongationPattern = RegExp(r"\b([a-zA-Z])\1{2,}");

      if (complexStutterPattern.hasMatch(word) ||
          prolongationPattern.hasMatch(word)) {
        return true;
      }
    }
    return false;
  }
}
