import 'package:flutter/material.dart';
import 'package:flutter_gap/flutter_gap.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shop/module%20auth/ui/pages/login/widgets/email_and_password.dart';


class EmailLoginScreen extends StatefulWidget {
  const EmailLoginScreen({super.key});
  @override
  State<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends State<EmailLoginScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding:
              EdgeInsets.only(left: 50.w, right: 50.w, bottom: 15.h, top: 5.h),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Gap(150.h),
                    EmailAndPassword(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
