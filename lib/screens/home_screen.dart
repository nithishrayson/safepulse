import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:safepulse/screens/live_location_screen.dart';
import 'package:safepulse/utils/app_colors.dart';
import 'package:safepulse/utils/app_text_styles.dart';
import 'package:safepulse/widgets/address_container.dart';
import 'package:safepulse/widgets/custom_appbar.dart';
import 'package:safepulse/widgets/sos_button.dart';
import '../services/sos_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Position? _currentPosition;
  String _currentAddress = "Fetching location...";
  final SOSService _sosService = SOSService();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _sosService.startListening();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enable location services.")),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Location permissions are permanently denied."),
          ),
        );
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentPosition = position;
    });

    _getAddressFromCoordinates(position.latitude, position.longitude);
  }

  Future<void> _getAddressFromCoordinates(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          _currentAddress =
              "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
        });
      }
    } catch (e) {
      print("Error fetching address: $e");
      setState(() {
        _currentAddress = "Unable to fetch address";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomAppBar(),
                const SizedBox(height: 40),

                // Emergency Message
                FadeIn(
                  duration: const Duration(milliseconds: 1000),
                  child: Column(
                    children: [
                      Text(
                        "Are you in an emergency?",
                        style: AppTextStyles.headingBlack.copyWith(
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Press the SOS button below or say 'Help' to trigger SOS.",
                        textAlign: TextAlign.center,
                        style: AppTextStyles.subHeadingBlack,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // SOS Button (Manual Trigger)
                FadeInUp(
                  duration: Duration(milliseconds: 1200),
                  child: SOSButton(),
                ),

                const SizedBox(height: 30),

                // Address Box (Live Location)
                FadeIn(
                  duration: Duration(milliseconds: 1300),
                  child: AddressContainer(address: _currentAddress),
                ),

                const SizedBox(height: 30),

                // View Live Location Button
                FadeInUp(
                  duration: Duration(milliseconds: 1400),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (_currentPosition != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => LiveLocationPage(
                                  position: _currentPosition,
                                ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Fetching location... Try again!"),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.sosButtonColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 20,
                      ),
                    ),
                    icon: Icon(Icons.location_on, color: Colors.white),
                    label: Text(
                      "View Live Location",
                      style: AppTextStyles.sosButtonText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
