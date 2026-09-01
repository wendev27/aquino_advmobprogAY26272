import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

// Purpose: Display app settings and preferences
// Responsibilities: Show dark mode toggle and other app settings
// Why this class exists: To provide a dedicated screen for user preferences

class SettingsScreen extends StatelessWidget {
  // Constructor for SettingsScreen
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<ThemeProvider>(
        // When ThemeProvider notifies listeners, this screen rebuilds automatically.
        // That is the core Provider pattern in action: UI updates from shared state.
        builder: (context, themeProvider, child) {
          return ListView(
            children: [
              // Dark mode setting
              SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Enable dark theme for the app'),
                secondary: Icon(
                  themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                ),
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  // Toggle theme when switch is changed
                  themeProvider.toggleTheme();
                },
              ),
              const Divider(),
              // App info section
              const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Lab Activity 1 & 2',
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      'Flutter State Management',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
