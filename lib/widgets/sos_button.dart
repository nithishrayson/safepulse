import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SOSButton extends StatefulWidget {
  @override
  _SOSButtonState createState() => _SOSButtonState();
}

class _SOSButtonState extends State<SOSButton> {
  bool _isSending = false;

  // 🚨 Fetch user details & contacts and send SOS
  Future<void> _sendSOS() async {
    if (_isSending) return;
    setState(() => _isSending = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showErrorDialog("User not logged in.");
        return;
      }

      // ✅ Fetch user details
      var userData = await _fetchUserDetails(user.uid);
      if (userData == null) {
        _showErrorDialog("User data not found.");
        return;
      }

      // ✅ Fetch emergency contacts
      List<Map<String, dynamic>> contacts = await _fetchEmergencyContacts(
        user.uid,
      );
      List<String> phoneNumbers =
          contacts
              .map((c) => c['phoneNumber']?.toString() ?? "Unknown")
              .toList(); // Extract only phone numbers

      print("📞 Emergency Contacts: $phoneNumbers");

      // 📍 Get user location
      Position position = await _determinePosition();
      double latitude = position.latitude;
      double longitude = position.longitude;

      // 🚀 Send SOS to API
      await _sendSOSRequest(
        userId: user.uid,
        name: userData['name'],
        email: userData['email'],
        phone: userData['phoneNumber'],
        latitude: latitude,
        longitude: longitude,
        contacts: phoneNumbers, // ✅ Only passing phone numbers
      );

      // ✅ Success Alert
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("✅ SOS Sent Successfully!")));
    } catch (e) {
      _showErrorDialog("An error occurred: $e");
    } finally {
      setState(() => _isSending = false);
    }
  }

  // 🔥 Fetch User Details from Firestore
  Future<Map<String, dynamic>?> _fetchUserDetails(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();

      return userDoc.exists ? userDoc.data() as Map<String, dynamic> : null;
    } catch (e) {
      print("❌ Error fetching user details: $e");
      return null;
    }
  }

  // 🔥 Fetch Emergency Contacts from Firestore (including subcollection)
  Future<List<Map<String, dynamic>>> _fetchEmergencyContacts(
    String userId,
  ) async {
    List<Map<String, dynamic>> contactsWithDetails = [];

    try {
      print("🚀 Fetching emergency contacts for user: $userId");

      // Fetch emergency contacts
      QuerySnapshot contactSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('emergencyContacts')
              .get();

      if (contactSnapshot.docs.isEmpty) {
        print("⚠️ No emergency contacts found in Firestore.");
        return [];
      }

      // Loop through each emergency contact document
      for (var contactDoc in contactSnapshot.docs) {
        var contactData = contactDoc.data() as Map<String, dynamic>;
        String contactId = contactDoc.id;

        print("📞 Contact Found: $contactData");

        // Fetch deeper "details" subcollection inside each contact
        QuerySnapshot detailsSnapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .collection('emergencyContacts')
                .doc(contactId)
                .collection('details') // Nested subcollection
                .get();

        List<Map<String, dynamic>> detailsList =
            detailsSnapshot.docs
                .map((doc) => doc.data() as Map<String, dynamic>)
                .toList();

        print("📂 Details for $contactId: $detailsList");

        // Store combined data
        contactsWithDetails.add({
          'phoneNumber': contactData['phoneNumber'],
          'name': contactData['name'],
          'details': detailsList, // Add nested details
        });
      }

      print("✅ Final Emergency Contacts Data: $contactsWithDetails");
      return contactsWithDetails;
    } catch (e) {
      print("❌ Error fetching emergency contacts: $e");
      return [];
    }
  }

  // 📡 Send SOS Request to API
  Future<void> _sendSOSRequest({
    required String userId,
    required String name,
    required String email,
    required String phone,
    required double latitude,
    required double longitude,
    required List<String> contacts,
  }) async {
    var url = Uri.parse("https://mangaiserver-nine.vercel.app/sendSOS");

    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": userId,
        "name": name,
        "email": email,
        "phone": phone,
        "latitude": latitude,
        "longitude": longitude,
        "contacts": contacts,
      }),
    );

    if (response.statusCode == 200) {
      print("✅ SOS sent successfully!");
    } else {
      print("❌ Failed to send SOS: ${response.body}");
    }
  }

  // 📍 Get User Location
  Future<Position> _determinePosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("❌ Location permission denied.");
      }
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // ✅ Test Fetch Emergency Contacts
  Future<void> testFetchEmergencyContacts() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    List<Map<String, dynamic>> contacts = await _fetchEmergencyContacts(userId);

    print("🔍 TEST CONTACTS:");
    for (var contact in contacts) {
      print("📞 Name: ${contact['name']}, Number: ${contact['phoneNumber']}");
      print("📂 Details: ${contact['details']}");
    }
  }

  // ❌ Show Error Alert
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Error"),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _sendSOS,
      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
      child:
          _isSending
              ? CircularProgressIndicator(color: Colors.white)
              : Text(
                "SEND SOS",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
    );
  }
}
