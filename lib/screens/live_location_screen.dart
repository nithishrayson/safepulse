import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:safepulse/screens/profile_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:safepulse/utils/app_colors.dart';
import 'package:safepulse/utils/app_text_styles.dart';
import 'package:safepulse/widgets/custom_loading.dart';

class LiveLocationPage extends StatefulWidget {
  final Position? position;

  LiveLocationPage({Key? key, this.position}) : super(key: key);

  @override
  _LiveLocationPageState createState() => _LiveLocationPageState();
}

class _LiveLocationPageState extends State<LiveLocationPage> {
  Position? _position;
  final MapController _mapController = MapController();
  bool _isLoading = true;
  String _batteryLevel = "Fetching...";
  String _networkStatus = "Checking...";
  String _lastUpdated = "Fetching...";
  final Battery _battery = Battery();

  @override
  void initState() {
    super.initState();
    _getLiveLocation();
    _fetchBatteryLevel();
    _fetchNetworkStatus();
  }

  Future<void> _fetchBatteryLevel() async {
    final batteryLevel = await _battery.batteryLevel;
    setState(() {
      _batteryLevel = "$batteryLevel%";
    });
  }

  Future<void> _fetchNetworkStatus() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _networkStatus = connectivityResult.toString().split('.').last;
    });
  }

  Future<void> _getLiveLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackBar("Enable location services.");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackBar("Location permission denied.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnackBar(
        "Location permission permanently denied. Change in settings.",
      );
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _position = position;
        _isLoading = false;
        _lastUpdated = "${DateTime.now().hour}:${DateTime.now().minute}";
      });

      Geolocator.getPositionStream(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
      ).listen((Position pos) {
        if (mounted) {
          setState(() {
            _position = pos;
            _lastUpdated = "${DateTime.now().hour}:${DateTime.now().minute}";
          });
          _mapController.move(LatLng(pos.latitude, pos.longitude), 15.0);
        }
      });
    } catch (e) {
      _showSnackBar("Failed to fetch location: $e");
    }
  }

  void _shareLocation() {
    if (_position != null) {
      String locationUrl =
          "https://www.google.com/maps/search/?api=1&query=${_position!.latitude},${_position!.longitude}";
      Share.share("My live location: $locationUrl");
    } else {
      _showSnackBar("Unable to share location.");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  void _sendEmergencyAlert() {
    if (_position != null) {
      String alertMessage =
          "🚨 Emergency Alert 🚨\nLocation: https://www.google.com/maps/search/?api=1&query=${_position!.latitude},${_position!.longitude}\nBattery: $_batteryLevel\nNetwork: $_networkStatus";
      Share.share(alertMessage);
    } else {
      _showSnackBar("Cannot send emergency alert without location.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Live Location", style: AppTextStyles.headingBlack),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: Colors.black),
            onPressed: _shareLocation,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // User Info & Location Details Card
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryRed,
                      const Color.fromARGB(255, 196, 67, 67),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      spreadRadius: 2,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 24,
                          backgroundImage: AssetImage(
                            "assets/images/profile.jpg",
                          ),
                        ),
                      ),
                      title: Text(
                        "Jennifer Richards",
                        style: AppTextStyles.subHeadingWhite.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        "Emergency Contact: +91 9876543210",
                        style: AppTextStyles.subHeadingWhite.copyWith(
                          fontSize: 14,
                        ),
                      ),
                      trailing: ClipOval(
                        child: Material(
                          color: const Color.fromARGB(
                            255,
                            0,
                            0,
                            0,
                          ).withOpacity(0.6),
                          child: InkWell(
                            splashColor: const Color.fromARGB(
                              255,
                              255,
                              255,
                              255,
                            ).withOpacity(0.6),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProfileScreen(),
                                ),
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Divider(color: Colors.black12, thickness: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _infoTile(
                            Icons.battery_full,
                            "Battery",
                            _batteryLevel,
                          ),
                          _infoTile(
                            Icons.network_cell,
                            "Network",
                            _networkStatus,
                          ),
                          _infoTile(
                            Icons.access_time_filled,
                            "Updated",
                            _lastUpdated,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Live Map
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  color: Colors.grey.shade300,
                  child:
                      _isLoading
                          ? Center(child: CustomLoadingAnimation())
                          : FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              center: LatLng(
                                _position!.latitude,
                                _position!.longitude,
                              ),
                              zoom: 15.0,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                                subdomains: ['a', 'b', 'c'],
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: LatLng(
                                      _position!.latitude,
                                      _position!.longitude,
                                    ),
                                    builder:
                                        (ctx) => Icon(
                                          Icons.location_pin,
                                          color: Colors.redAccent,
                                          size: 35,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Emergency Alert Button
            ElevatedButton.icon(
              onPressed: _sendEmergencyAlert,
              icon: Icon(Icons.warning, color: Colors.white),
              label: Text(
                "Send Emergency Alert",
                style: AppTextStyles.subHeadingWhite,
              ),

              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String title, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 22),
        Text(title, style: TextStyle(color: Colors.white, fontSize: 12)),
        Text(value, style: TextStyle(color: Colors.white, fontSize: 14)),
      ],
    );
  }
}
