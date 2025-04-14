import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<void> requestMicrophonePermission() async {
    var status = await Permission.microphone.request();
    if (status.isDenied) {
      print("Microphone permission denied!");
    }
  }
}
