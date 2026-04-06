import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shop/core/misc/build_divider.dart';
import 'package:flutter_gap/flutter_gap.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shop/module%20auth/ui/core/widgets/default_button.dart';
import 'package:shop/routing/routes.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding:
              EdgeInsets.only(left: 50.w, right: 50.w, bottom: 15.h, top: 5.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BuildDivider.buildDivider(),
              Center(
                child: Text(
                  "App for artists.\nAtomic",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25.0.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Gap(10.h),
              BuildDivider.buildDivider(),
              Gap(10.h),
              DefaultButton(
                text: "Sign In",
                onPressed: () => context.push(Routes.signInScreen),
              ),
              Gap(1.h),
              DefaultButton(
                text: "Log In",
                onPressed: () => {
                  context.push(Routes.loginScreen),
                  },
              ),
            ],
          ),
        ),
      ),
    );
  }
}