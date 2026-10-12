import 'package:flutter/material.dart';

import '../services/user_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _age = TextEditingController();
  final _contactNo = TextEditingController();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final UserService _userService = UserService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    for (final controller in [
      _firstName,
      _lastName,
      _age,
      _contactNo,
      _username,
      _email,
      _password,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Required' : null;

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final response = await _userService.createAccount(
        loginType: LoginType.firebase,
        firstName: _firstName.text,
        lastName: _lastName.text,
        age: int.parse(_age.text),
        contactNo: _contactNo.text,
        username: _username.text,
        email: _email.text,
        password: _password.text,
      );
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        (route) => false,
        arguments: response,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              'Firebase Authentication account',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
                'Your profile is saved in Firebase and cached locally on this device.'),
            const SizedBox(height: 20),
            _field(_firstName, 'First name', validator: _required),
            _field(_lastName, 'Last name', validator: _required),
            _field(
              _age,
              'Age',
              keyboardType: TextInputType.number,
              validator: (value) {
                final age = int.tryParse(value?.trim() ?? '');
                return age == null || age <= 0 || age > 120
                    ? 'Enter a valid age'
                    : null;
              },
            ),
            _field(
              _contactNo,
              'Contact number',
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (_required(value) != null) return 'Required';
                return RegExp(r'^\+?[0-9 ()-]{7,20}$').hasMatch(value!.trim())
                    ? null
                    : 'Enter a valid contact number';
              },
            ),
            _field(_username, 'Username', validator: _required),
            _field(
              _email,
              'Email address',
              keyboardType: TextInputType.emailAddress,
              validator: (value) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                      .hasMatch(value?.trim() ?? '')
                  ? null
                  : 'Enter a valid email address',
            ),
            _field(
              _password,
              'Password (at least 6 characters)',
              obscureText: _obscurePassword,
              validator: (value) =>
                  (value?.length ?? 0) < 6 ? 'Use at least 6 characters' : null,
              suffixIcon: IconButton(
                icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(
                  () => _obscurePassword = !_obscurePassword,
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createAccount,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create account'),
              ),
            ),
            TextButton(
              onPressed: _isLoading ? null : () => Navigator.pop(context),
              child: const Text('Back to login'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
