import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

class NotificationsScreen extends StatelessWidget {
  final List<Map<String, String>> notifications = [
    {
      "title": "Emergency Alert",
      "subtitle": "High-risk area detected near you.",
      "time": "2 min ago",
    },
    {
      "title": "SOS Response",
      "subtitle": "Help is on the way!",
      "time": "10 min ago",
    },
    {
      "title": "Safety Update",
      "subtitle": "Check your emergency contacts.",
      "time": "30 min ago",
    },
    {
      "title": "Weather Warning",
      "subtitle": "Storm alert issued in your area.",
      "time": "1 hour ago",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                FadeInDown(
                  duration: Duration(milliseconds: 800),
                  child: Text(
                    "Notifications",
                    style: AppTextStyles.headingBlack.copyWith(fontSize: 24),
                  ),
                ),

                SizedBox(height: 20),

                // Notifications List
                Expanded(
                  child: ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      return FadeInLeft(
                        duration: Duration(milliseconds: 800 + (index * 100)),
                        child: Card(
                          color: Colors.white.withOpacity(0.9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: Icon(
                              Icons.notifications_active,
                              color: Colors.redAccent,
                            ),
                            title: Text(
                              notifications[index]['title']!,
                              style: AppTextStyles.headingBlack,
                            ),
                            subtitle: Text(
                              notifications[index]['subtitle']!,
                              style: AppTextStyles.subHeadingBlack,
                            ),
                            trailing: Text(
                              notifications[index]['time']!,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      );
                    },
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
