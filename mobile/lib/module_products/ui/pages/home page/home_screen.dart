import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shop/module_auth/ui/pages/login/login_screen.dart';
import 'package:shop/module_auth/ui/pages/login/view_models/login_viewmodel.dart';
import 'package:shop/module_auth/ui/pages/logout/view_models/logout_viewmodel.dart';
import 'package:shop/module_auth/ui/pages/logout/widgets/logout_button.dart';

import 'package:shop/core/widgets/no_internet.dart';
import 'package:shop/module_products/ui/pages/product/product.dart';
import 'package:shop/routing/routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
          return connected ? _homePage(context) : const BuildNoInternet();
        },
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    // Navigate based on selected index
    switch (index) {
      case 0:
        context.go(UserRoutes.homeScreen);
        break;
      case 1:
        context.go(UserRoutes.chatsScreen);
        break;
      case 2:
        context.go(UserRoutes.profileScreen);
        break;
      case 3:
        context.go(UserRoutes.settingsScreen);
        break;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  Widget _homePage(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SearchBar(
          hintText: 'Search anything',
        ),
      ),
      body: SafeArea(
        child: ScrollConfiguration(
          behavior: const ScrollBehavior().copyWith(overscroll: false),
          child: GridView.builder(

            padding: const EdgeInsets.all(10), // Отступ вокруг всей сетки
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 колонки
              crossAxisSpacing: 10, // Отступ по горизонтали между карточками
              mainAxisSpacing: 10, // Отступ по вертикали между карточками
              childAspectRatio: 0.7, // Соотношение сторон карточки (ширина/высота)
              // Позволяет сделать карточки выше, чем шире
            ),
            itemCount: 20, // Количество товаров
            itemBuilder: (context, index) {
              return ProductCard(
                productName: "Кроссовки Nike Air Max ${index + 1}",
                price:
                    "${(129.99 + index * 5).toStringAsFixed(2)} \$", // Примерная цена
                imageUrl:
                    "https://picsum.photos/id/${10 + index}/300/400", // Случайные изображения
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Главная"),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline_rounded),
              label: "Сообщения"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded), label: "Профиль"),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            label: "Настройки",
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }
}




// import 'package:awesome_dialog/awesome_dialog.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_offline/flutter_offline.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// import '../../core/misc/extensions.dart';
// import '../../routing/routes.dart';
// import '/theming/styles.dart';
// import '../../../widgets/app_text_button.dart';
// import 'package:shop/core/widgets/no_internet.dart';
// import 'package:shop/core/widgets/loading_indicator.dart';
// import 'package:shop/module auth/ui/ViewModel/auth_cubit.dart';
// import '../../../theming/colors.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: OfflineBuilder(
//         connectivityBuilder: (
//           BuildContext context,
//           List<ConnectivityResult> connectivity,
//           Widget child,
//         ) {
//           final bool connected = connectivity != ConnectivityResult.none;
//           return connected ? _homePage(context) : const BuildNoInternet();
//         },
//         child: const Center(
//           child: CircularProgressIndicator(
//             color: ColorsManager.mainBlue,
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void initState() {
//     super.initState();
//     BlocProvider.of<AuthCubit>(context);
//   }

//   SafeArea _homePage(BuildContext context) {
//     return SafeArea(
//       child: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 15.w),
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               SizedBox(
//                 height: 200.h,
//                 width: 200.w,
//                 child: FirebaseAuth.instance.currentUser!.photoURL != null
//                     ? CachedNetworkImage(
//                         imageUrl: FirebaseAuth.instance.currentUser!.photoURL!,
//                         placeholder: (context, url) =>
//                             Image.asset('assets/images/loading.gif'),
//                         fit: BoxFit.cover,
//                       )
//                     : Image.asset('assets/images/placeholder.png'),
//               ),
//               Text(
//                 FirebaseAuth.instance.currentUser!.displayName!,
//                 style: TextStyles.font15DarkBlue500Weight
//                     .copyWith(fontSize: 30.sp),
//               ),
//               BlocConsumer<AuthCubit, AuthState>(
//                 buildWhen: (previous, current) => previous != current,
//                 listenWhen: (previous, current) => previous != current,

//                 listener: (context, state) async {
//                   if (state is AuthLoading) {
//                     MyProgressIndicator.showProgressIndicator(context);
//                   } else if (state is UserSignedOut) {
//                     context.pop();
//                     context.pushNamedAndRemoveUntil(
//                       Routes.welcomeScreen,
//                       predicate: (route) => false,
//                     );
//                   } else if (state is AuthError) {
//                     await AwesomeDialog(
//                       context: context,
//                       dialogType: DialogType.info,
//                       animType: AnimType.rightSlide,
//                       title: 'Sign out error',
//                       desc: state.message,
//                     ).show();
//                   }
//                 },
//                 builder: (context, state) {
//                   return AppTextButton(
//                     buttonText: 'Sign Out',
//                     textStyle: TextStyles.font15DarkBlue500Weight,
//                     onPressed: () {
//                       try {
//                         GoogleSignIn.instance.disconnect();
//                       } finally {
//                         context.read<AuthCubit>().signOut();
//                       }
//                     },
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }