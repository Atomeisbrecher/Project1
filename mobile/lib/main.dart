import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop/firebase_options.dart';
import 'package:shop/routing/router.dart';
import 'package:provider/provider.dart';
import 'main_development.dart' as development;

Future<void> preloadSVGs(List<String> paths) async {
  for (final path in paths) {
    final loader = SvgAssetLoader(path);
    await svg.cache.putIfAbsent(
      loader.cacheKey(null),
      () => loader.loadBytes(null),
    );
  }
}


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ),
    ScreenUtil.ensureScreenSize(),
    preloadSVGs(['assets/svgs/google_logo.svg'])
  ]);
  development.main();
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp.router(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: ThemeMode.system,
          debugShowCheckedModeBanner: false,
          routerConfig: router(context.read(), context.read()),
        );
      },
    );
  }
}

//flutter build apk --dart-define=API_KEY=my_secret_key