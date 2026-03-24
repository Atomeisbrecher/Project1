// import 'package:flutter/material.dart';
// import 'profile.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         useMaterial3: true,
//       ),
//       home: const MainPage(),
//     );
//   }
// }

// class MainPage extends StatefulWidget {
//   const MainPage({super.key});

//   @override
//   State<MainPage> createState() => _MainPageState();
// }

// class _MainPageState extends State<MainPage> {
//   int _selectedIndex = 0;

//   // Бесконечная ленивая загрузка данных
//   final List<Map<String, String>> _items = [];
//   final ScrollController _scrollController = ScrollController();
//   bool _isLoading = false;
//   int _currentPage = 1;
//   final int _itemsPerPage = 20;

//   @override
//   void initState() {
//     super.initState();
//     _loadMoreItems(); // Загружаем первые элементы

//     // Добавляем слушатель скролла для пагинации
//     _scrollController.addListener(_onScroll);
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }

//   void _onScroll() {
//     if (_scrollController.position.pixels >=
//         _scrollController.position.maxScrollExtent - 200) {
//       _loadMoreItems();
//     }
//   }

//   Future<void> _loadMoreItems() async {
//     if (_isLoading) return;

//     setState(() {
//       _isLoading = true;
//     });

//     // Имитация загрузки данных из сети
//     await Future.delayed(const Duration(seconds: 1));

//     setState(() {
//       // Добавляем новые элементы
//       for (int i = 0; i < _itemsPerPage; i++) {
//         final itemIndex = (_currentPage - 1) * _itemsPerPage + i + 1;
//         _items.add({
//           'title': 'Товар $itemIndex',
//           'price': '${(itemIndex) * 100} ₽',
//           'description':
//               'Краткое описание товара $itemIndex. Здесь может быть текст о характеристиках и особенностях.',
//           'imageUrl': 'https://picsum.photos/400/400?random=$itemIndex',
//         });
//       }
//       _currentPage++;
//       _isLoading = false;
//     });
//   }

//     void _onNavigationItemSelected(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });

//     // Если выбрана вкладка профиля (индекс 2)
//     if (index == 2) {
//       _navigateToProfile();
//     }
//   }

//   // Метод для перехода на страницу профиля
//   void _navigateToProfile() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => const ProfilePage(),
//       ),
//     ).then((result) {
//       // Этот код выполнится после возвращения со страницы профиля
//       if (result != null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Вернулись с профиля: $result')),
//         );
//       }

//       // Возвращаем выделение на главную после возвращения
//       setState(() {
//         _selectedIndex = 0;
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: CustomScrollView(
//         controller: _scrollController,
//         slivers: [
//           SliverAppBar(
//             floating: true,
//             pinned: true,
//             snap: true,
//             expandedHeight: 120,
//             flexibleSpace: FlexibleSpaceBar(
//               titlePadding: const EdgeInsets.only(left: 16, bottom: 8),
//               title: const Text(
//                 'Магазин',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//               background: Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                     colors: [Colors.blue.shade700, Colors.purple.shade700],
//                   ),
//                 ),
//               ),
//             ),
//             bottom: PreferredSize(
//               preferredSize: const Size.fromHeight(60),
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Container(
//                   height: 44,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(12),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.1),
//                         blurRadius: 8,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: TextField(
//                     decoration: InputDecoration(
//                       hintText: 'Поиск товаров...',
//                       prefixIcon: const Icon(Icons.search, color: Colors.grey),
//                       suffixIcon: IconButton(
//                         icon: const Icon(Icons.filter_list, color: Colors.grey),
//                         onPressed: () {
//                           // Действие для фильтрации
//                         },
//                       ),
//                       border: InputBorder.none,
//                       contentPadding: const EdgeInsets.symmetric(vertical: 12),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),

//           // Ленивая сетка с карточками
//           SliverPadding(
//             padding: const EdgeInsets.all(16),
//             sliver: SliverGrid(
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 5, // 2 колонки
//                 crossAxisSpacing: 16,
//                 mainAxisSpacing: 8,
//                 childAspectRatio: 0.65, // Соотношение высоты к ширине
//               ),
//               delegate: SliverChildBuilderDelegate(
//                 (context, index) {
//                   if (index >= _items.length) {
//                     // Показываем индикатор загрузки в последнем элементе
//                     return const Center(
//                       child: CircularProgressIndicator(),
//                     );
//                   }

//                   final item = _items[index];
//                   return Card(
//                     elevation: 3,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Изображение
//                         Expanded(
//                           flex: 3,
//                           child: ClipRRect(
//                             borderRadius: const BorderRadius.vertical(
//                               top: Radius.circular(12),
//                             ),
//                             child: Image.network(
//                               item['imageUrl']!,
//                               fit: BoxFit.cover,
//                               width: double.infinity,
//                               loadingBuilder: (context, child, progress) {
//                                 if (progress == null) return child;
//                                 return Container(
//                                   color: Colors.grey[300],
//                                   child: const Center(
//                                     child: CircularProgressIndicator(
//                                       strokeWidth: 2,
//                                     ),
//                                   ),
//                                 );
//                               },
//                               errorBuilder: (context, error, stackTrace) {
//                                 return Container(
//                                   color: Colors.grey[300],
//                                   child: const Center(
//                                     child: Icon(Icons.broken_image, size: 30),
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//                         ),

//                         // Контент карточки
//                         Expanded(
//                           flex: 2,
//                           child: Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 // Цена
//                                 Text(
//                                   item['price']!,
//                                   style: const TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.green,
//                                   ),
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                                 const SizedBox(height: 4),

//                                 // Название
//                                 Text(
//                                   item['title']!,
//                                   style: const TextStyle(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                                 const SizedBox(height: 2),

//                                 // Описание
//                                 Text(
//                                   item['description']!,
//                                   style: const TextStyle(
//                                     fontSize: 11,
//                                     color: Colors.grey,
//                                   ),
//                                   maxLines: 2,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//                 childCount: _items.length + (_isLoading ? 1 : 0),
//               ),
//             ),
//           ),
//         ],
//       ),

//       // Нижняя навигация
//       bottomNavigationBar: NavigationBar(
//         selectedIndex: _selectedIndex,
//         onDestinationSelected: (index) {
//           setState(() {
//             _selectedIndex = index;
//           });
//         },
//         destinations: const [
//           NavigationDestination(
//             icon: Icon(Icons.home_outlined),
//             selectedIcon: Icon(Icons.home),
//             label: 'Главная',
//           ),
//           NavigationDestination(
//             icon: Icon(Icons.message_outlined),
//             selectedIcon: Icon(Icons.message),
//             label: 'Сообщения',
//           ),
//           NavigationDestination(
//             icon: Icon(Icons.person_outline),
//             selectedIcon: Icon(Icons.person),
//             label: 'Профиль',
//           ),
//         ],
//       ),
//     );

//   }
// }

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/flutter_svg.dart';

// import 'firebase_options.dart';
// import 'routing/app_router.dart';
// import 'routing/routes.dart';
// import 'theming/colors.dart';

// late String initialRoute;
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Future.wait([
//     Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     ),
//     ScreenUtil.ensureScreenSize(),
//     //preloadSVGs(['assets/svgs/google_logo.svg'])
//   ]);
//   FirebaseAuth.instance.authStateChanges().listen(
//     (user) {
//       if (user == null || !user.emailVerified) {
//         initialRoute = Routes.loginScreen;
//       } else {
//         initialRoute = Routes.homeScreen;
//       }
//     },
//   );
//   // runApp(
//   //   ChangeNotifierProvider(
//   //     create: (context) => ThemeProvider(),
//   //     child: MyApp(router: AppRouter()),
//   //   )
//   // );

// }

// class MyApp extends StatelessWidget {
//   final AppRouter router;

//   const MyApp({super.key, required this.router});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       //home: const SignUpScreen(),
//       theme: Provider.of<ThemeProvider>(context).themeData,
//       onGenerateRoute: router.generateRoute,
//       initialRoute: initialRoute,
//     );
//   }
// }

//https://mobbin.com/apps/revolut-business-ios-93ad9ceb-a163-41da-ba7a-9f07c737fc2a/0c4c334c-e3a5-4395-89be-c7666aaafdf5/screens

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Future.wait([
//     Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     ),
//     ScreenUtil.ensureScreenSize(),
//     preloadSVGs(['assets/svgs/google_logo.svg'])
//   ]);

//   FirebaseAuth.instance.authStateChanges().listen(
//     (user) {
//       if (user == null || !user.emailVerified) {
//         initialRoute = Routes.loginScreen;
//       } else {
//         initialRoute = Routes.homeScreen;
//       }
//     },
//   );

//   runApp(MainApp(router: AppRouter()));
// }

// Future<void> preloadSVGs(List<String> paths) async {
//   for (final path in paths) {
//     final loader = SvgAssetLoader(path);
//     await svg.cache.putIfAbsent(
//       loader.cacheKey(null),
//       () => loader.loadBytes(null),
//     );
//   }
// }

// class MainApp extends StatelessWidget {
//   final AppRouter router;

//   const MainApp({super.key, required this.router});

//   @override
//   Widget build(BuildContext context) {
//     return ScreenUtilInit(
//       designSize: const Size(360, 690),
//       minTextAdapt: true,
//       splitScreenMode: true,
//       builder: (_, child) {
//         return MaterialApp(
//           title: 'Login & Signup App',
//           theme: ThemeData(
//             useMaterial3: true,
//             textSelectionTheme: const TextSelectionThemeData(
//               cursorColor: ColorsManager.mainBlue,
//               selectionColor: Color.fromARGB(188, 36, 124, 255),
//               selectionHandleColor: ColorsManager.mainBlue,
//             ),
//           ),
//           onGenerateRoute: router.generateRoute,
//           debugShowCheckedModeBanner: false,
//           initialRoute: initialRoute,
//         );
//       },
//     );
//   }
// }

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
          routerConfig: router(context.read()),
        );
      },
    );
  }
}

//flutter build apk --dart-define=API_KEY=my_secret_key