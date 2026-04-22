import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';


class ImageButton extends StatelessWidget {
  final String? assetPathSVG;
  final Function onTap;

  const ImageButton({
    super.key,
    this.assetPathSVG,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      
      onTap: () {
        onTap();
      },
      child: Align(
        alignment: Alignment.center,
        child: SvgPicture.asset(
          assetPathSVG!,
          width: 40.w,
          height: 40.h,
        ),
      ),
    );
  }
}
