import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'constants.dart';
import 'providers/theme_provider.dart';
import 'providers/counter_provider.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/dual_counter_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/signin_screen.dart';

// Purpose: Entry point of the Flutter application
// Responsibilities: Initialize app, set up providers, and configure theme
// Why this file exists: To bootstrap the application with all necessary configurations

void main() async {
  // Load environment variables from .env file
  await dotenv.load(fileName: ".env");
  
  // Run the Flutter app
  runApp(const MyApp());
}

// Main application widget
// Responsibilities: Set up the app structure with providers and theme
class MyApp extends StatelessWidget {
  // Constructor for MyApp
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider allows multiple providers to be used in the app
    return MultiProvider(
      providers: [
        // ThemeProvider is app-wide state for the dark/light setting.
        // Every screen that needs the theme can read it from this provider.
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        // CounterProvider shows the "app state" idea from the lab:
        // the value survives across navigation, unlike local setState() data.
        ChangeNotifierProvider(
          create: (_) => CounterProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        // Consumer rebuilds when ThemeProvider notifies listeners
        builder: (context, themeProvider, child) {
          return MaterialApp(
            // App title
            title: 'Lab Activity',
            
            // Debug banner disabled for cleaner look
            debugShowCheckedModeBanner: false,
            
            // Theme configuration based on ThemeProvider
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
            ),
            
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            
            // The current theme mode comes from provider state, so changing it
            // updates the whole app without manually passing a value through widgets.
            themeMode: themeProvider.themeMode,
            
            // The app starts at the splash screen to check whether the user is
            // already logged in before showing the protected parts of the app.
            initialRoute: '/splash',
            routes: {
              '/splash': (context) => const SplashScreen(),
              '/signin': (context) => const SigninScreen(),
              '/home': (context) {
                final args = ModalRoute.of(context)?.settings.arguments;
                final userId = args is Map<String, dynamic>
                    ? (args['id'] as int? ?? currentUserId)
                    : currentUserId;
                return MainNavigation(userId: userId);
              },
              '/settings': (context) => const SettingsScreen(),
            },
          );
        },
      ),
    );
  }
}

// Main navigation widget
// Purpose: Provide bottom navigation between screens
// Responsibilities: Manage navigation state and display appropriate screen
// Why this class exists: To provide navigation between Home and Settings screens
class MainNavigation extends StatefulWidget {
  final int userId;

  // Constructor for MainNavigation
  const MainNavigation({super.key, this.userId = currentUserId});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  // Current selected tab index
  int _currentIndex = 0;

  // List of screens for navigation
  // Why this exists: To easily map tab index to screen
  late final List<Widget> _screens = [
    const HomeScreen(),
    // Lab 3 adds the cart tab to the main app shell so users can move between
    // the product list and the shopping cart without leaving the navigation flow.
    CartScreen(userId: widget.userId),
    const ProfileScreen(),
    const DualCounterScreen(),
    const SettingsScreen(),
  ];

  // Handle tab tap
  // Inputs: Index of the tapped tab
  // Why this exists: To update the current tab when user taps navigation
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Display the current screen based on selected tab
      body: _screens[_currentIndex],
      
      // Bottom navigation bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          // Home tab
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          // Cart tab
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          // Profile tab
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          // Counter tab
          BottomNavigationBarItem(
            icon: Icon(Icons.countertops),
            label: 'Counter',
          ),
          // Settings tab
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
