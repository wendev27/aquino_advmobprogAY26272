import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/user_service.dart';
import 'cart_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  late Future<Map<String, dynamic>> _userFuture;

  @override
  void initState() {
    super.initState();
    _reloadUser();
  }

  void _reloadUser() {
    _userFuture = _userService.getUserData();
  }

  Future<void> _logout() async {
    await _userService.signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
  }

  Future<void> _editUsername(User user) async {
    final controller = TextEditingController(text: user.username);
    final newUsername = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update username'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Username'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (newUsername == null || newUsername.trim().isEmpty) return;
    try {
      await _userService.updateUsername(newUsername);
      if (!mounted) return;
      setState(_reloadUser);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username updated.')),
      );
    } catch (error) {
      _showError(error);
    }
  }

  Future<void> _changePassword() async {
    final current = TextEditingController();
    final next = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: current,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Current password'),
            ),
            TextField(
              controller: next,
              obscureText: true,
              decoration: const InputDecoration(
                  labelText: 'New password (6+ characters)'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Update'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      current.dispose();
      next.dispose();
      return;
    }
    try {
      await _userService.resetPasswordFromCurrentPassword(
        currentPassword: current.text,
        newPassword: next.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated.')),
        );
      }
    } catch (error) {
      _showError(error);
    } finally {
      current.dispose();
      next.dispose();
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
          'This removes the signed-in Firebase account. Local profile data will also be cleared.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _userService.deleteAccount();
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
      appBar: AppBar(title: const Text('Profile')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Could not load profile.'));
          }
          final user = User.fromJson(snapshot.data!);
          final isFirebase = user.provider == LoginType.firebase.name;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: Colors.blue.shade50,
                  backgroundImage:
                      user.image.isNotEmpty ? NetworkImage(user.image) : null,
                  child: user.image.isEmpty
                      ? const Icon(Icons.person, size: 44, color: Colors.blue)
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  user.fullName.isEmpty ? 'User' : user.fullName,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text('@${user.username}'),
                Text(
                  isFirebase
                      ? 'Firebase Authentication'
                      : 'DummyJSON Authentication',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 20),
                Card(
                  child: Column(
                    children: [
                      _detail(Icons.email_outlined, 'Email', user.email),
                      _detail(Icons.cake_outlined, 'Age',
                          user.age?.toString() ?? 'Not provided'),
                      _detail(
                          Icons.phone_outlined,
                          'Contact',
                          user.contactNo.isEmpty
                              ? 'Not provided'
                              : user.contactNo),
                      _detail(Icons.badge_outlined, 'User ID', '#${user.id}'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('Update username'),
                  onTap: () => _editUsername(user),
                ),
                if (isFirebase)
                  ListTile(
                    leading: const Icon(Icons.lock_outline),
                    title: const Text('Change password'),
                    onTap: _changePassword,
                  ),
                ListTile(
                  leading: const Icon(Icons.shopping_cart_outlined),
                  title: const Text('View my cart'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => CartScreen(userId: user.id)),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Log out'),
                  onTap: _logout,
                ),
                if (isFirebase)
                  ListTile(
                    leading:
                        const Icon(Icons.delete_forever, color: Colors.red),
                    title: const Text('Delete account'),
                    onTap: _deleteAccount,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _detail(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 180),
        child: Text(value, textAlign: TextAlign.end),
      ),
    );
  }
}
