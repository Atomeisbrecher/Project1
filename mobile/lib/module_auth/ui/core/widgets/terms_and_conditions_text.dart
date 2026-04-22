import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TermsAndConditionsText extends StatelessWidget {
  const TermsAndConditionsText({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
            text: 'By logging, you agree to our',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ).copyWith(height: 4.h),
          ),
          TextSpan(
            text: ' Terms & Conditions',
            style: TextStyle(
              color: Colors.white54,
            ),
          ),
          TextSpan(
            text: ' and',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ).copyWith(height: 4.h),
          ),
          TextSpan(
            text: ' PrivacyPolicy.',
            style: TextStyle(
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}