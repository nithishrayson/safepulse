import 'package:flutter/material.dart';
import 'package:safepulse/utils/app_colors.dart';
import 'package:safepulse/utils/app_text_styles.dart';

class AddressContainer extends StatelessWidget {
  final String address;

  const AddressContainer({Key? key, required this.address}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(Icons.location_on, color: AppColors.primaryRed, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              address,
              style: AppTextStyles.subHeadingBlack.copyWith(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
