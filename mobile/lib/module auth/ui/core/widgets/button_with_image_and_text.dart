import 'package:flutter/material.dart';
import 'package:flutter_gap/flutter_gap.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class ButtonWithImageAndText extends StatelessWidget {
  final String serviceName;
  final String? assetPathSVG;
  final IconData? icon;
  final VoidCallback onPressed;

  const ButtonWithImageAndText({
    super.key,
    required this.serviceName,
    this.assetPathSVG,
    this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          onPressed();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          side: BorderSide(color: Colors.grey.shade300),
          padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 16.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.r),
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (assetPathSVG != null)
              Align(
                alignment: Alignment.centerLeft,
                child: SvgPicture.asset(
                  assetPathSVG!,
                  width: 24.w,
                  height: 24.h,
                ),
              )
            else if (icon != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Icon(
                  icon,
                  size: 24.r,
                ),
              ),
            Gap(8.w),
            Center(
              child: Text(
                "Continue with $serviceName",
                style: TextStyle(
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
