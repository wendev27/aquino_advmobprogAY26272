import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/user_service.dart';

// Purpose: Display user profile information
// Responsibilities: Show user details, provide logout functionality
// Why this class exists: To provide a dedicated screen for user profile management

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  late Future<User> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _userService.getUser();
  }

  // Handle logout process
  Future<void> _logout() async {
    // Clearing SharedPreferences removes the saved login session, and then the app
    // forces navigation back to the sign-in screen.
    await _userService.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: FutureBuilder<User>(
        // Loads the saved session user before displaying profile details.
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Could not load profile'));
          }

          final user = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: Colors.blue.shade50,
                  backgroundImage: user.image.isNotEmpty ? NetworkImage(user.image) : null,
                  child: user.image.isEmpty
                      ? const Icon(Icons.person, size: 44, color: Colors.blue)
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  user.fullName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text('@${user.username}'),
                const SizedBox(height: 24),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.email_outlined),
                        title: const Text('Email'),
                        trailing: Text(user.email),
                      ),
                      ListTile(
                        leading: const Icon(Icons.wc_outlined),
                        title: const Text('Gender'),
                        trailing: Text(user.gender),
                      ),
                      ListTile(
                        leading: const Icon(Icons.badge_outlined),
                        title: const Text('User ID'),
                        trailing: Text('#${user.id}'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    label: const Text('View My Cart'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CartScreen(userId: user.id)),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                    onPressed: _logout,
                    child: const Text(
                      'Log Out',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
