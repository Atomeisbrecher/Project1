import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:go_router/go_router.dart';
import 'package:shop/core/misc/build_divider.dart';
import 'package:shop/core/widgets/no_internet.dart';
import 'package:flutter_gap/flutter_gap.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shop/module%20auth/ui/core/widgets/button_with_image_and_text.dart';
import 'package:shop/module%20auth/ui/core/widgets/text_button.dart';
import 'package:shop/module%20auth/ui/pages/login/view_models/login_viewmodel.dart';
import 'package:shop/routing/routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.viewModel,
  });

  final LoginViewModel viewModel;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void didUpdateWidget(covariant LoginScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.viewModel.login.removeListener(_onResult);
    widget.viewModel.login.addListener(_onResult);
  }

  @override
  void initState() {
    super.initState();
    widget.viewModel.login.addListener(_onResult);
  }

  @override
  void dispose() {
    widget.viewModel.login.removeListener(_onResult);
    super.dispose();
  }

  void _onResult() {
    if (widget.viewModel.login.completed) {
      widget.viewModel.login.clearResult();
      context.go(Routes.homeScreen);
    }

    if (widget.viewModel.login.error) {
      widget.viewModel.login.clearResult();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OfflineBuilder(
        connectivityBuilder: (
          BuildContext context,
          List<ConnectivityResult> connectivity,
          Widget child,
        ) {
          final bool connected =
              !connectivity.contains(ConnectivityResult.none);
          return connected ? _loginPage(context) : child;
        },
        child: const BuildNoInternet(),
      ),
    );
  }

  SafeArea _loginPage(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding:
            EdgeInsets.only(left: 50.w, right: 50.w, bottom: 15.h, top: 5.h),
        child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BuildDivider.buildDivider(),
                Center(
                  child: Text(
                    "Log in to Atomic",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30.0.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Gap(10.h),
                BuildDivider.buildDivider(),
                Gap(10.h),
                ButtonWithImageAndText(
                  serviceName: "Email",
                  icon: Icons.email_outlined,
                  onPressed: () =>
                      widget.viewModel.login.execute(),
                ),
                Gap(1.h),
                ButtonWithImageAndText(
                  serviceName: "Google",
                  assetPathSVG: 'assets/svgs/google_logo.svg',
                  onPressed: () => 
                  widget.viewModel.signInWithGoogle.execute()
                ),
                Gap(20.h),
                MyTextButton(
                  text: "Don't have an account?",
                  buttonText: "Sign In",
                  routeName: Routes.signInScreen,
                ),
              ],
            )
        ),
    );
  }
}
