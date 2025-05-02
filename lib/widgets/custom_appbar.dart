import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safepulse/screens/profile_screen.dart';
import '../utils/app_text_styles.dart';

class CustomAppBar extends StatefulWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  CustomAppBarState createState() => CustomAppBarState();
}

class CustomAppBarState extends State<CustomAppBar> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String username = "User";
  String? profileImage;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // 🔄 Fetch user data from Firestore
  void _fetchUserData() async {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        if (!mounted) return;
        setState(() {
          username = userDoc['name'] ?? "User"; // Fetch username
          profileImage = userDoc['profileImage']; // Fetch profile pic
          isLoading = false;
        });
      }
    } catch (e) {
      // Removed print statement
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome back,", style: AppTextStyles.subHeadingBlack),
            isLoading
                ? Text("Loading...", style: AppTextStyles.headingBlack)
                : Text(username, style: AppTextStyles.headingBlack),
          ],
        ),

        // Profile Picture
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            );
          },
          child: CircleAvatar(
            radius: 28,
            backgroundImage:
                isLoading
                    ? AssetImage("assets/images/profile.jpg") as ImageProvider
                    : profileImage != null
                    ? NetworkImage(profileImage!)
                    : AssetImage("assets/images/profile.jpg") as ImageProvider,
          ),
        ),
      ],
    );
  }
}
