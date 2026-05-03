import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/single_child_widget.dart';
import 'package:provider/provider.dart';
import 'package:shop/module_auth/data/repository/auth/auth_repository.dart';
import 'package:shop/module_auth/data/repository/auth/auth_repository_remote.dart';
import 'package:shop/module_auth/data/repository/auth/token_storage.dart';
import 'package:shop/module_auth/data/services/api/auth_api_client.dart';
import 'package:shop/module_chat/data/repository/chat_repo/chat_repository.dart';
import 'package:shop/module_chat/data/repository/chat_repo/chat_repository_impl.dart';
import 'package:shop/module_chat/data/repository/message_repo/message_repository.dart';
import 'package:shop/module_chat/data/repository/message_repo/message_repository_impl.dart';
import 'package:shop/module_chat/data/services/chat_cache/chat_cache_service.dart';
import 'package:shop/module_chat/data/services/chat_cache/chat_cache_service_impl.dart';
import 'package:shop/module_chat/data/services/chat_client/chat_api_service.dart';
import 'package:shop/module_chat/data/services/chat_client/chat_api_service_remote.dart';
import 'package:shop/module_chat/data/services/message_service/message_api_service.dart';
import 'package:shop/module_chat/data/services/message_service/message_api_service_remote.dart';
import 'package:shop/module_profile/data/repository/user/user_repository.dart';
import 'package:shop/module_profile/data/repository/user/user_repository_remote.dart';
import 'package:shop/module_profile/data/services/shared_preferences_service.dart';
import 'package:shop/module_profile/data/services/user_api_service.dart';
import 'package:shop/services/dio_service/dio_api_client.dart';
import 'package:shop/services/websocket_service/websocket_service.dart';
import 'package:shop/services/websocket_service/websocket_service_remote.dart';





List<SingleChildWidget> get providersRemote {
  return [
    Provider(create: (context) => AuthService()),
    Provider(create: (context) => const FlutterSecureStorage()),
    Provider<TokenStorage>(create: (context) => TokenStorage()),
    Provider<DioApiClient>(create: (context) => DioApiClient(secureStorage: context.read())),
    Provider<WebSocketService>(create: (context) => WebSocketServiceRemote(context.read())),
    Provider(create: (context) => SharedPreferencesService(SharedPreferences.getInstance())),
    Provider<UserApiService> (create: (context) => UserApiService(context.read())),
    Provider<UserRepository> (create: (context) => UserRepositoryRemote(context.read(), context.read()),),
    Provider<ChatApiService>(
      create: (context) => ChatApiServiceRemote(
        dioClient: context.read(),
      ),
    ),
    Provider<MessageApiService>(
      create: (context) => MessageApiServiceRemote(
        dioClient: context.read(),
      ),
    ),
    Provider<ChatCacheService>(
      create: (context) => ChatCacheServiceImpl(),
    ),
    ChangeNotifierProvider(
      create: (context) =>
          OAuthRepositoryRemote(
                authService: context.read(),
                secureStorage: context.read(),
                webSocketServiceRemote: context.read(),
              )
              as OAuthRepository,
    ),
    ChangeNotifierProvider(
      create: (context) => ChatRepositoryImpl(
        chatApiService: context.read(),
        chatCacheService: context.read(),
        webSocketService: context.read(),
      ) as ChatRepository,
    ),
    ChangeNotifierProvider<MessageRepository>(
      create: (context) => MessageRepositoryImpl(
        messageApiService: context.read(),
        webSocketService: context.read(),
        chatCacheService: context.read(),
      ),
    ),
  ];
}


// List<SingleChildWidget> get providersLocal {
//   return [
//     ChangeNotifierProvider.value(value: AuthRepositoryDev() as AuthRepository),
//     Provider.value(value: LocalDataService()),
//   ];
// }