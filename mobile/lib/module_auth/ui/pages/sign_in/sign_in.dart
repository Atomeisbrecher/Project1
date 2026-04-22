import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gap/flutter_gap.dart';
import 'package:shop/module_auth/ui/core/widgets/image_button.dart';
import 'package:shop/module_auth/ui/core/widgets/text_button.dart';
import 'package:shop/module_auth/ui/pages/sign_in/view_models/sign_in_viewmodel.dart';

import '../login/widgets/email_and_password.dart';
import '../../core/widgets/terms_and_conditions_text.dart';

import '../../../../routing/routes.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({
    super.key,
    required this.viewModel,
    });
  final SignInViewModel viewModel;
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding:
              EdgeInsets.only(left: 30.w, right: 30.w, bottom: 15.h, top: 5.h),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Create Account',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.blueAccent,
                    )),
                Gap(8.h),
                Text(
                  'Sign in now and start exploring all that our\napp has to offer. We\'re excited to welcome\nyou to our community!',
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
                Gap(8.h),
                Column(
                  children: [
                    EmailAndPassword(
                      isSignInPage: true,
                      viewModel: widget.viewModel,
                    ),
                    Gap(10.h),
                    Text(
                      "Or sign in with",
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    Gap(5.h),
                    ImageButton(
                      onTap: () =>
                          widget.viewModel.signInWithGoogle.execute(),
                      assetPathSVG: 'assets/svgs/google_logo.svg',
                    ),
                    const TermsAndConditionsText(),
                    Gap(15.h),
                    MyTextButton(
                        text: "Already have an account?",
                        buttonText: "Log In",
                        routeName: Routes.loginScreen)
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}
