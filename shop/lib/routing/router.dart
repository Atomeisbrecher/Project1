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
      initialLocation: Routes.welcomeScreen,
      debugLogDiagnostics: true,
      //redirect: _redirect,
      redirect: (context, state) => _redirect(context, state, oAuthRepository),
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

Future<String?> _redirect(BuildContext context, GoRouterState state,
    OAuthRepository authRepository) async {
  // //final loggedIn = await context.read<OAuthRepository>().isAuthenticated;
  // final loggedIn = await authRepository.isAuthenticated;
  // final loggingIn = state.matchedLocation == Routes.loginScreen;
  // if (!loggedIn) {
  //   return Routes.welcomeScreen;
  // }

  // if (loggingIn) {
  //   return Routes.homeScreen;
  // }

  // return null;

  final loggedIn = await authRepository.isAuthenticated;

  final isLoggingIn = state.matchedLocation == Routes.loginScreen;
  final isSigningIn = state.matchedLocation == Routes.signInScreen;
  final isWelcome = state.matchedLocation == Routes.welcomeScreen;

  // 4. Защита от бесконечного цикла:
  // Если не авторизован И пытается зайти на закрытый экран -> отправляем на welcome
  if (!loggedIn && !isLoggingIn && !isSigningIn && !isWelcome) {
    return Routes.welcomeScreen;
  }

  // Если авторизован И находится на экране входа -> отправляем на главную
  if (loggedIn && (isLoggingIn || isWelcome || isSigningIn)) {
    return Routes.homeScreen;
  }

  return null;
}
