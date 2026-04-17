import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:shop/module%20auth/data/repository/auth/auth_repository.dart';
import 'package:shop/module%20auth/domain/use_cases/google_sign_in.dart';
import 'package:shop/module%20auth/ui/pages/login/login_screen.dart';
import 'package:shop/module%20auth/ui/pages/login/view_models/login_viewmodel.dart';
import 'package:shop/module%20auth/ui/pages/sign_in/sign_in.dart';
import 'package:shop/module%20auth/ui/pages/sign_in/view_models/sign_in_viewmodel.dart';
import 'package:shop/module%20auth/ui/pages/welcome_screen/welcome_screen.dart';
import 'package:shop/module%20products/ui/pages/home%20page/home_screen.dart';
import 'package:shop/routing/routes.dart';

GoRouter router(OAuthRepository oAuthRepository) => GoRouter(
      initialLocation: Routes.homeScreen,
      debugLogDiagnostics: true,
      redirect: _redirect,
      refreshListenable: oAuthRepository,
      routes: [
        GoRoute(
            path: Routes.welcomeScreen,
            builder: (context, state) {
              return WelcomeScreen();
            }),
        GoRoute(
          path: Routes.loginScreen,
          builder: (context, state) {
            return LoginScreen(
              viewModel: LoginViewModel(oAuthRepository: context.read(), googleSignIn: GoogleSignInUseCase(oAuthRepository)),
            );
          },
        ),
        GoRoute(
          path: Routes.homeScreen,
          builder: (context, state) {
            return HomeScreen();
          },
        ),
        GoRoute(
            path: Routes.signInScreen,
            builder: (context, state) {
              return SignInScreen(
                viewModel: SignInViewModel(oAuthRepository: context.read()),
              );
            }),
      ],
    );

Future<String?> _redirect(BuildContext context, GoRouterState state) async {
  final isAuthenticated = await context.read<OAuthRepository>().isAuthenticated;
  final location = state.matchedLocation;

  final authRoutes = [
    Routes.welcomeScreen,
    Routes.loginScreen,
    Routes.restoreScreen,
    Routes.signInScreen,
    Routes.createPassword,
    Routes.emailAndPasswordScreen,
  ];


  if (!isAuthenticated && !authRoutes.contains(location)) {
    return Routes.welcomeScreen;
  }

  if (isAuthenticated && authRoutes.contains(location)) {
    return Routes.homeScreen;
  }

  return null;
}
