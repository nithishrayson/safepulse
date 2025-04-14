import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safepulse/screens/login_screen.dart';
import '../utils/app_colors.dart'; // Ensure you have a login screen

class ProfileScreen extends StatelessWidget {
  void _logoutUser(BuildContext context) async {
    bool confirmLogout = await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Logout"),
            content: Text("Are you sure you want to log out?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text("Logout"),
              ),
            ],
          ),
    );

    if (confirmLogout == true) {
      try {
        await FirebaseAuth.instance.signOut();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false, // Remove all previous routes
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Logout failed: ${e.toString()}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header Section
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(30),
                  ),
                ),
              ),

              // Back Button
              Positioned(
                top: 50,
                left: 20,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              // Logout Button
              Positioned(
                top: 50,
                right: 20,
                child: IconButton(
                  icon: Icon(
                    Icons.power_settings_new,
                    color: Colors.black,
                    size: 28,
                  ),
                  onPressed: () => _logoutUser(context), // Call logout function
                ),
              ),

              // Profile Picture & Name
              Positioned(
                left: 20,
                bottom: -40,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage(
                        "assets/images/profile.jpg",
                      ), // Add user profile image
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Jennifer Richards",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          "Mangai User",
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 50),

          // Profile Options List
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 20),
              children: [
                buildProfileOption("Personal Information", Icons.person),
                buildProfileOption("Login & Security", Icons.lock),
                buildProfileOption("Notifications", Icons.notifications),
                buildProfileOption("Help & Support", Icons.help),
                buildProfileOption("Legal & Privacy", Icons.privacy_tip),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProfileOption(String title, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1),
          ],
        ),
        child: ListTile(
          leading: Icon(icon, color: Colors.deepPurple),
          title: Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          trailing: Icon(Icons.arrow_forward_ios, size: 18),
          onTap: () {
            // Navigate to respective screen
          },
        ),
      ),
    );
  }
}
