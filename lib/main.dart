import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:safepulse/screens/bottom_navigation_bar.dart';
import 'package:safepulse/screens/emergency_contacts_screen.dart';
import 'package:safepulse/screens/login_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(MangaiApp());
}

class MangaiApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mangai Safety App',
      theme: ThemeData(primarySwatch: Colors.purple),
      home: AuthCheck(),
    );
  }
}

// 🔥 Auth Check Widget
class AuthCheck extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasData) {
          return FutureBuilder<DocumentSnapshot>(
            future:
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(snapshot.data!.uid)
                    .get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (userSnapshot.hasData && userSnapshot.data!.exists) {
                var userData = userSnapshot.data!;
                List<dynamic> emergencyContacts =
                    userData['emergencyContacts'] ?? [];

                if (emergencyContacts.isEmpty) {
                  return EmergencyContactScreen(userId: snapshot.data!.uid);
                } else {
                  return BottomNavScreen();
                }
              }

              return LoginScreen();
            },
          );
        } else {
          return LoginScreen();
        }
      },
    );
  }
}
