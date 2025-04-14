import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'dart:convert';

class SOSService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterTts _flutterTts = FlutterTts();

  // 🎤 Start Listening for Voice Commands
  void startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print("Speech recognition status: $status"),
      onError: (error) => print("Speech recognition error: $error"),
    );

    if (available) {
      _speech.listen(
        onResult: (result) {
          String recognizedWords = result.recognizedWords.toLowerCase();
          print("Detected: $recognizedWords");

          if (recognizedWords.contains("help") ||
              recognizedWords.contains("sos")) {
            triggerSOS();
          }
        },
      );
    } else {
      print("Speech recognition not available");
    }
  }

  // 🚨 Trigger SOS
  Future<void> triggerSOS() async {
    print("🚨 SOS Triggered! Fetching emergency contacts...");

    String? userId = _auth.currentUser?.uid;
    if (userId == null) {
      print("❌ User not logged in.");
      return;
    }

    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        print("❌ User not found in Firestore.");
        return;
      }

      print("📄 User Document Data: ${userDoc.data()}");

      List<String> contacts = List<String>.from(
        userDoc['emergencyContacts'] ?? [],
      );

      if (contacts.isEmpty) {
        print("❌ No emergency contacts found.");
        return;
      }

      print("✅ Emergency contacts found: $contacts");

      // Send SOS API Request
      await sendSOS(contacts);

      // 🔊 Voice Confirmation
      await _flutterTts.speak("SOS message sent to emergency contacts.");
    } catch (e) {
      print("❌ Error triggering SOS: $e");
    }
  }

  // 📡 Send SOS Request to API
  Future<void> sendSOS(List<dynamic> contacts) async {
    const String apiUrl = "https://mangaiserver-nine.vercel.app/sendSOS";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contacts": contacts,
          "message": "🚨 SOS Alert! I am in danger. Please help!",
        }),
      );

      if (response.statusCode == 200) {
        print("✅ SOS message sent successfully!");
      } else {
        print("❌ Failed to send SOS: ${response.body}");
      }
    } catch (e) {
      print("❌ Error sending SOS: $e");
    }
  }
}
