import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:safepulse/screens/emergency_contacts_screen.dart'; // Import the next screen

class SuccessScreen extends StatefulWidget {
  final String message;
  final String userId;

  SuccessScreen({required this.message, required this.userId});

  @override
  _SuccessScreenState createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  bool _fadeOut = false;

  @override
  void initState() {
    super.initState();

    // Trigger fade-out before exiting
    Future.delayed(Duration(milliseconds: 1700), () {
      if (mounted) {
        setState(() {
          _fadeOut = true;
        });
      }
    });

    // Automatically navigate to Emergency Contacts Screen after 2 seconds
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EmergencyContactScreen(userId: widget.userId),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeOut(
        animate: _fadeOut,
        duration: Duration(milliseconds: 500),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BounceInDown(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                  ),
                  padding: EdgeInsets.all(20),
                  child: Icon(Icons.check, color: Colors.white, size: 50),
                ),
              ),
              SizedBox(height: 20),
              FlipInX(
                child: Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
