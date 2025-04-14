import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'home_screen.dart';
import 'notification_screen.dart';

class BottomNavScreen extends StatefulWidget {
  @override
  _BottomNavScreenState createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [HomeScreen(), NotificationsScreen()],
      ),
      bottomNavigationBar: ConvexAppBar(
        backgroundColor: Colors.white,
        activeColor: Colors.redAccent,
        color: Colors.grey[600],
        curveSize: 80,
        height: 60,
        initialActiveIndex: _selectedIndex,
        items: const [
          TabItem(icon: Icons.home),
          TabItem(icon: Icons.contacts),
          TabItem(icon: Icons.notifications),
        ],
        onTap: (index) {
          _pageController.jumpToPage(index); // Smoothly replace pages
        },
      ),
    );
  }
}
