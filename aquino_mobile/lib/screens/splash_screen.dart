import 'package:flutter/material.dart';
import '../services/user_service.dart';

// Purpose: Display splash screen and check authentication status
// Responsibilities: Show loading, check if user is logged in, navigate appropriately
// Why this class exists: To provide initial app loading experience with auth check

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  // Check if user is logged in and navigate accordingly
  Future<void> _checkAuthentication() async {
    // This delay simulates the app startup screen while the authentication check runs.
    await Future.delayed(const Duration(milliseconds: 1500));

    final loggedIn = await _userService.isLoggedIn();
    if (!mounted) return;

    if (loggedIn) {
      final userData = await _userService.getUserData();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home', arguments: userData);
    } else {
      Navigator.pushReplacementNamed(context, '/signin');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade900,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.storefront, size: 48, color: Colors.blue.shade900),
            ),
            const SizedBox(height: 16),
            const Text(
              'Lab Activity',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation(Colors.amber),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
