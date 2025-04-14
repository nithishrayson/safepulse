import 'package:flutter/material.dart';
import 'package:safepulse/services/speech_to_text.dart';
import '../services/sos_service.dart';
import '../services/permissions.dart';

class VoiceSOSPage extends StatefulWidget {
  @override
  _VoiceSOSPageState createState() => _VoiceSOSPageState();
}

class _VoiceSOSPageState extends State<VoiceSOSPage> {
  final SpeechService _speechService = SpeechService();
  final SOSService _sosService = SOSService();

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    await PermissionService.requestMicrophonePermission();
  }

  void _onKeywordDetected() {
    _sosService.triggerSOS();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Voice-Activated SOS")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            _speechService.startListening(_onKeywordDetected);
          },
          child: const Text("Start Listening"),
        ),
      ),
    );
  }
}
