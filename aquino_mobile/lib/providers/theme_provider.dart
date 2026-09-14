import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  // Keeps the theme state in one place so listening widgets can update
  // whenever light or dark mode changes.
  bool _isDark = false;

  bool get isDark => _isDark;

  ThemeData get lightTheme => ThemeData.light();
  ThemeData get darkTheme => ThemeData.dark();

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }

  void setDarkMode(bool value) {
    if (_isDark == value) return;
    _isDark = value;
    notifyListeners();
  }
}
