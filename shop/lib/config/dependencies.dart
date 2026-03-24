import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/single_child_widget.dart';
import 'package:provider/provider.dart';
import 'package:shop/module%20auth/data/repository/auth/auth_repository.dart';
import 'package:shop/module%20auth/data/repository/auth/auth_repository_remote.dart';
import 'package:shop/module auth/data/services/api/auth_api_client.dart';
import 'package:shop/module auth/data/services/api/api_client.dart';




List<SingleChildWidget> get providersRemote {
  return [
    Provider(create: (context) => AuthService()),
    Provider(create: (context) => ApiClient()),
    Provider(create: (context) => FlutterSecureStorage()),
    ChangeNotifierProvider(
      create: (context) =>
          OAuthRepositoryRemote(
                authService: context.read(),
                apiClient: context.read(),
                secureStorage: context.read(),
              )
              as OAuthRepository,
    ),
    // Provider(
    //   create: (context) =>
    //       UserRepositoryRemote(apiClient: context.read()) as UserRepository,
    // ),
    // ..._sharedProviders,
  ];
}


// List<SingleChildWidget> get providersLocal {
//   return [
//     ChangeNotifierProvider.value(value: AuthRepositoryDev() as AuthRepository),
//     Provider.value(value: LocalDataService()),
//   ];
// }