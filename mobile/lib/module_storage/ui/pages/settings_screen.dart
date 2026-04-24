import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shop/module_auth/ui/pages/logout/view_models/logout_viewmodel.dart';
import 'package:shop/module_auth/ui/pages/logout/widgets/logout_button.dart';
import 'package:shop/routing/routes.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen({
    super.key,
    required this.logOutViewModel,
    });

  final LogoutViewModel logOutViewModel;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _selectedIndex = 3;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0: context.go(UserRoutes.homeScreen); break;
      case 1: context.go(UserRoutes.chatsScreen); break;
      case 2: context.go(UserRoutes.profileScreen); break;
      case 3: context.go(UserRoutes.settingsScreen); break;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          Center(
            child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: LogoutButton(viewModel: widget.logOutViewModel),
            ),
          ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: "Главная"),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), activeIcon: Icon(Icons.chat_bubble), label: "Чаты"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: "Профиль"),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: "Настройки"),
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