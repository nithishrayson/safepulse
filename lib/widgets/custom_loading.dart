import 'package:flutter/material.dart';
import 'package:safepulse/utils/app_colors.dart';
import 'package:safepulse/utils/app_text_styles.dart';
import 'package:animate_do/animate_do.dart';

class CustomLoadingAnimation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors
              .primaryGradient
              .colors[0], // Use the same gradient as the homepage
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Circular container for loading animation
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppColors.primaryRed, Colors.redAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.redAccent.withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Add GIF in the center
                    ClipOval(
                      child: Image.asset(
                        'assets/images/man_loading.gif', // Use your GIF file here
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Loading text with clean fade-in animation
              FadeInUp(
                duration: const Duration(milliseconds: 1500),
                child: Text(
                  "Loading...",
                  style: AppTextStyles.headingWhite.copyWith(
                    color: AppColors.primaryRed,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
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
