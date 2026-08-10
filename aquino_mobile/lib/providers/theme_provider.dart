import 'package:flutter/material.dart';

// Purpose: Manage the application's theme (dark/light mode)
// Responsibilities: Store theme preference and notify listeners when theme changes
// Why this class exists: To provide app-wide theme state using Provider pattern
// This is application-wide state that needs to be accessed from multiple screens

class ThemeProvider extends ChangeNotifier {
  // Current theme mode (dark or light)
  ThemeMode _themeMode = ThemeMode.light;

  // Getter for current theme mode
  // Outputs: Current ThemeMode
  ThemeMode get themeMode => _themeMode;

  // Check if dark mode is currently active
  // Outputs: true if dark mode, false otherwise
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // Toggle between dark and light mode
  // Why this exists: To allow users to switch themes
  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }
    
    // Notify all listeners that theme has changed
    notifyListeners();
  }

  // Set theme to a specific mode
  // Inputs: ThemeMode to set
  // Why this exists: To allow direct theme setting if needed
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}
