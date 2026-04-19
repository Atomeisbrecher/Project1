import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/single_child_widget.dart';
import 'package:provider/provider.dart';
import 'package:shop/module%20auth/data/repository/auth/auth_repository.dart';
import 'package:shop/module%20auth/data/repository/auth/auth_repository_remote.dart';
import 'package:shop/module auth/data/services/api/auth_api_client.dart';
import 'package:shop/module%20auth/data/repository/auth/token_storage.dart';
import 'package:shop/module%20auth/data/services/api/api_interceptors.dart';
import 'package:shop/module%20chat/domain/chat/chat_repository.dart';
import 'package:shop/module%20chat/data/repository/chat_repository_impl.dart';
import 'package:shop/module%20chat/data/services/chat%20client/chat_api_service.dart';
import 'package:shop/module%20chat/data/services/chat%20client/chat_api_service_remote.dart';
import 'package:shop/module%20chat/data/services/chat%20client/dio_chat_client.dart';
import 'package:shop/module%20chat/data/services/chat%20cache/chat_cache_service.dart';
import 'package:shop/module%20chat/data/services/chat%20cache/chat_cache_service_impl.dart';
import 'package:shop/module%20chat/data/services/websocket%20service/websocket_service.dart';
import 'package:shop/module%20chat/data/services/websocket%20service/websocket_service_remote.dart';
import 'package:shop/module%20chat/domain/message/message_repository.dart';
import 'package:shop/module%20chat/data/repository/message_repository_impl.dart';
import 'package:shop/module%20chat/data/services/message%20service/message_api_service.dart';
import 'package:shop/module%20chat/data/services/message%20service/message_api_service_remote.dart';




List<SingleChildWidget> get providersRemote {
  return [
    Provider(create: (context) => AuthService()),
    Provider(create: (context) => const FlutterSecureStorage()),
    Provider<TokenStorage>(create: (context) => TokenStorage()),
    Provider<DioChatClient>(
      create: (context) => DioChatClient(
        secureStorage: context.read(),
      ),
    ),
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
    Provider<WebSocketService>(
      create: (context) => WebSocketServiceRemote(),
    ),
    Provider<ChatRepository>(
      create: (context) => ChatRepositoryImpl(
        chatApiService: context.read(),
        chatCacheService: context.read(),
        webSocketService: context.read(),
      ),
    ),
    Provider<MessageRepository>(
      create: (context) => MessageRepositoryImpl(
        messageApiService: context.read(),
        webSocketService: context.read(),
      ),
    ),
    ChangeNotifierProvider(
      create: (context) =>
          OAuthRepositoryRemote(
                authService: context.read(),
                secureStorage: context.read(),

              )
              as OAuthRepository,
    ),
  ];
}


// List<SingleChildWidget> get providersLocal {
//   return [
//     ChangeNotifierProvider.value(value: AuthRepositoryDev() as AuthRepository),
//     Provider.value(value: LocalDataService()),
//   ];
// }