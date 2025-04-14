import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();

  Future<void> startListening(Function onKeywordDetected) async {
    bool available = await _speech.initialize(
      onError: (error) => print("Speech Error: $error"),
    );

    if (available) {
      _speech.listen(
        onResult: (result) {
          String recognizedWords = result.recognizedWords.toLowerCase();
          print("Detected: $recognizedWords");

          if (recognizedWords.contains("help") || recognizedWords.contains("danger")) {
            onKeywordDetected();
          }
        },
      );
    } else {
      print("Speech recognition not available");
    }
  }

  void stopListening() {
    _speech.stop();
  }
}
