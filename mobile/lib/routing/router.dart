import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:shop/module_auth/data/repository/auth/auth_repository.dart';
import 'package:shop/module_auth/domain/use_cases/google_sign_in.dart';
import 'package:shop/module_auth/ui/pages/login/login_screen.dart';
import 'package:shop/module_auth/ui/pages/login/view_models/login_viewmodel.dart';
import 'package:shop/module_auth/ui/pages/logout/view_models/logout_viewmodel.dart';
import 'package:shop/module_auth/ui/pages/sign_in/sign_in.dart';
import 'package:shop/module_auth/ui/pages/sign_in/view_models/sign_in_viewmodel.dart';
import 'package:shop/module_auth/ui/pages/welcome_screen/welcome_screen.dart';
import 'package:shop/module_chat/data/repository/chat_repo/chat_repository.dart';
import 'package:shop/module_chat/data/repository/message_repo/message_repository.dart';
import 'package:shop/module_chat/domain/chat/chat.dart';
import 'package:shop/module_chat/domain/use_cases/get_chats.dart';
import 'package:shop/module_chat/domain/use_cases/search_chats.dart';
import 'package:shop/module_chat/domain/use_cases/search_users_chats.dart';
import 'package:shop/module_chat/domain/use_cases/sync_chats.dart';
import 'package:shop/module_chat/domain/use_cases/get_messages.dart';
import 'package:shop/module_chat/domain/use_cases/send_message.dart';
import 'package:shop/module_chat/domain/use_cases/edit_message.dart';
import 'package:shop/module_chat/domain/use_cases/delete_message.dart';
import 'package:shop/module_chat/domain/use_cases/forward_message.dart';
import 'package:shop/module_chat/ui/pages/chat_list/view_models/chat_list_viewmodel.dart';
import 'package:shop/module_chat/ui/pages/chat_detail/view_models/chat_detail_viewmodel.dart';
import 'package:shop/module_chat/ui/pages/chat_list/chat_list_screen.dart';
import 'package:shop/module_chat/ui/pages/chat_detail/chat_detail_screen.dart';
import 'package:shop/module_products/ui/pages/home%20page/home_screen.dart';
import 'package:shop/module_profile/ui/pages/my_profile/my_profile.dart';
import 'package:shop/module_storage/ui/pages/settings_screen.dart';
import 'package:shop/routing/routes.dart';

GoRouter router(OAuthRepository oAuthRepository, ChatRepository chatRepository) => GoRouter(
      initialLocation: Routes.homeScreen,
      debugLogDiagnostics: true,
      redirect: _redirect,
      refreshListenable: oAuthRepository,
      routes: [
        // Приветственное скрин
        GoRoute(
            path: Routes.welcomeScreen,
            builder: (context, state) {
              return WelcomeScreen();
            }),
        // Скрин авторизации
        GoRoute(
          path: Routes.loginScreen,
          builder: (context, state) {
            return LoginScreen(
              viewModel: LoginViewModel(oAuthRepository: context.read(), googleSignIn: GoogleSignInUseCase(oAuthRepository)),
            );
          },
        ),
        // Скрин домашний
        GoRoute(
          path: Routes.homeScreen,
          builder: (context, state) {
            return HomeScreen();
          },
        ),
        // Скрин регистрации
        GoRoute(
            path: Routes.signInScreen,
            builder: (context, state) {
              return SignInScreen(
                viewModel: SignInViewModel(oAuthRepository: context.read()),
              );
            }),
        // Скрин чатов
        GoRoute(
          path: UserRoutes.chatsScreen,
          builder: (context, state) {
            return ChatListScreen(
              viewModel: ChatListViewModel(
                getChatsUseCase: GetChatsUseCase(chatRepository: chatRepository),
                searchChatsUseCase: SearchChatsUseCase(chatRepository: chatRepository),
                syncChatsUseCase: SyncChatsUseCase(chatRepository: chatRepository),
                searchUsersChatsUseCase: SearchUsersChatsUseCase(chatRepository: chatRepository)
              ),
              logOutViewModel: LogoutViewModel(oAuthRepository: oAuthRepository),
            );
          },
          // Скрин конкретного чата
          routes: [
            GoRoute(
              path: ':chatId',
              builder: (context, state) {
                final chat = state.extra as Chat;
                final messageRepository = context.read<MessageRepository>();
                return ChatDetailScreen(
                  chat: chat,
                  viewModel: ChatDetailViewModel(
                    getMessagesUseCase: GetMessagesUseCase(messageRepository: messageRepository),
                    sendMessageUseCase: SendMessageUseCase(messageRepository: messageRepository),
                    editMessageUseCase: EditMessageUseCase(messageRepository: messageRepository),
                    deleteMessageUseCase: DeleteMessageUseCase(messageRepository: messageRepository),
                    forwardMessageUseCase: ForwardMessageUseCase(messageRepository: messageRepository),
                  ),
                );
              },
            ),
          ],
        ),
        // Скрин профиля
        GoRoute(
          path: UserRoutes.profileScreen,
          builder: (context, state) {
            return MyProfileScreen(
              logOutViewModel: LogoutViewModel(oAuthRepository: oAuthRepository),
            );
          },
        ),
        GoRoute(
          path: UserRoutes.settingsScreen,
          builder: (context, state) {
            return SettingsScreen(
              logOutViewModel: LogoutViewModel(oAuthRepository: oAuthRepository),
            );
          },
        ),
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
