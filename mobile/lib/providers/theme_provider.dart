import 'package:flutter/material.dart';
import 'package:shop/themes/theme.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = darkMode;

  ThemeData get themeData => _themeData;

  set themeData(ThemeData data) {
    _themeData = data;
    notifyListeners();
  }

  void toggleTheme() {
    if (_themeData == lightMode) {
      themeData = darkMode;
    } else {
      themeData = lightMode;
    }
  }

  // static ThemeData darkTheme() {
  //   return ThemeData.dark();
  // }

  //   static ThemeData lightTheme() {
  //   return ThemeData.light();
  // }
}