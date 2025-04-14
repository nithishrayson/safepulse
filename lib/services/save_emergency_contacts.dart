import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> saveEmergencyContacts(String userId, List<String> contacts) async {
  try {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'emergencyContacts': contacts,
    });

    print("✅ Contacts saved successfully!");
  } catch (e) {
    print("❌ Error saving contacts: $e");
  }
}
