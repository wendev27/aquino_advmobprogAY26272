import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../providers/theme_provider.dart';
import '../services/user_service.dart';

// Purpose: Display app settings and preferences
// Responsibilities: Show dark mode toggle and other app settings
// Why this class exists: To provide a dedicated screen for user preferences

class SettingsScreen extends StatefulWidget {
  // Constructor for SettingsScreen
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final UserService _userService = UserService();
  late Future<Map<String, dynamic>> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _userService.getUserData();
  }

  Future<void> _logout() async {
    await _userService.signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
  }

  Future<void> _deleteAccount() async {
    final passwordController = TextEditingController();
    final currentPassword = await showDialog<String>(
      context: context,
      builder: (context) {
        var hasPassword = false;
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Delete account?'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'This permanently removes the signed-in Firebase account and its saved local profile. Enter your current password to confirm.',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  onChanged: (value) => setDialogState(
                    () => hasPassword = value.isNotEmpty,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Current password',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: hasPassword
                    ? () => Navigator.pop(context, passwordController.text)
                    : null,
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
    );
    passwordController.dispose();
    if (currentPassword == null) return;
    try {
      await _userService.deleteAccount(currentPassword: currentPassword);
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
    } catch (error) {
      _showError(error);
    }
  }

  void _showError(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
    );
  }

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
              const Divider(),
              FutureBuilder<Map<String, dynamic>>(
                future: _userFuture,
                builder: (context, snapshot) {
                  final isFirebase = snapshot.hasData &&
                      User.fromJson(snapshot.data!).provider ==
                          LoginType.firebase.name;
                  return Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.logout),
                        title: const Text('Log out'),
                        onTap: _logout,
                      ),
                      if (isFirebase)
                        ListTile(
                          leading: const Icon(Icons.delete_forever,
                              color: Colors.red),
                          title: const Text('Delete account'),
                          onTap: _deleteAccount,
                        ),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
