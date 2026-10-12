import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../models/user.dart';

enum LoginType { dummyJson, firebase }

/// Centralizes authentication, session persistence, and account operations.
/// DummyJSON remains API/token based. Firebase uses the FirebaseAuth SDK.
/// Extra Firebase profile fields are local because this project has no database.
class UserService {
  firebase_auth.FirebaseAuth get _firebaseAuth =>
      firebase_auth.FirebaseAuth.instance;

  Future<Map<String, dynamic>> signIn({
    required String identifier,
    required String password,
    required LoginType loginType,
  }) async {
    if (identifier.trim().isEmpty || password.isEmpty) {
      throw const FormatException('Username/email and password are required.');
    }
    switch (loginType) {
      case LoginType.dummyJson:
        return loginUser(identifier.trim(), password);
      case LoginType.firebase:
        _ensureFirebaseReady();
        try {
          final credential = await _firebaseAuth.signInWithEmailAndPassword(
            email: identifier.trim(),
            password: password,
          );
          final user = credential.user;
          if (user == null) throw Exception('Firebase returned no user.');
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('loginType', LoginType.firebase.name);
          await _saveFirebaseUser(user);
          return getUserData();
        } on firebase_auth.FirebaseAuthException catch (error) {
          throw Exception(_firebaseErrorMessage(error));
        }
    }
  }

  /// Backwards-compatible entry point for the original Lab 4 flow.
  Future<Map<String, dynamic>> loginUser(
      String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'expiresInMins': 60,
        }),
      );
      if (response.statusCode == 200) {
        final data = Map<String, dynamic>.from(jsonDecode(response.body));
        data['provider'] = LoginType.dummyJson.name;
        await saveUserData(data);
        return data;
      }
      if (response.statusCode == 401) {
        throw Exception('Invalid username or password.');
      }
      throw Exception('DummyJSON request failed (${response.statusCode}).');
    } on FormatException {
      rethrow;
    } catch (error) {
      throw Exception('DummyJSON login failed: $error');
    }
  }

  Future<Map<String, dynamic>> createAccount({
    required LoginType loginType,
    required String firstName,
    required String lastName,
    required int age,
    required String contactNo,
    required String username,
    required String email,
    required String password,
  }) async {
    _validateSignup(
      firstName: firstName,
      lastName: lastName,
      age: age,
      contactNo: contactNo,
      username: username,
      email: email,
      password: password,
    );
    if (loginType == LoginType.dummyJson) {
      throw Exception(
        'DummyJSON is a demo login API and does not persist new accounts.',
      );
    }

    _ensureFirebaseReady();
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) throw Exception('Firebase returned no user.');
      await user.updateDisplayName('$firstName $lastName'.trim());
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('loginType', LoginType.firebase.name);
      await prefs.setString('username', username.trim());
      await prefs.setString('firstName', firstName.trim());
      await prefs.setString('lastName', lastName.trim());
      await prefs.setInt('age', age);
      await prefs.setString('contactNo', contactNo.trim());
      await _saveFirebaseUser(user);
      return getUserData();
    } on firebase_auth.FirebaseAuthException catch (error) {
      throw Exception(_firebaseErrorMessage(error));
    }
  }

  Future<void> signOut({LoginType? loginType}) async {
    final activeType = loginType ?? await _getLoginType();
    if (activeType == LoginType.firebase && _firebaseIsReady) {
      await _firebaseAuth.signOut();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<void> logout() => signOut();

  Future<void> updateUsername(String username) async {
    final value = username.trim();
    if (value.isEmpty) throw const FormatException('Username is required.');
    final type = await _getLoginType();
    if (type == LoginType.firebase) {
      _ensureFirebaseReady();
      if (_firebaseAuth.currentUser == null) {
        throw Exception('No Firebase user is signed in.');
      }
      await _firebaseAuth.currentUser!.updateDisplayName(value);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', value);
  }

  Future<void> deleteAccount({String? currentPassword}) async {
    final type = await _getLoginType();
    if (type == LoginType.firebase) {
      _ensureFirebaseReady();
      final user = _firebaseAuth.currentUser;
      if (user == null) throw Exception('No Firebase user is signed in.');
      try {
        await user.delete();
      } on firebase_auth.FirebaseAuthException catch (error) {
        throw Exception(_firebaseErrorMessage(error));
      }
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<void> resetPasswordFromCurrentPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (currentPassword.isEmpty || newPassword.length < 6) {
      throw const FormatException(
        'Current password is required and the new password must be at least 6 characters.',
      );
    }
    if (await _getLoginType() != LoginType.firebase) {
      throw Exception(
          'Password changes are only available for Firebase accounts.');
    }
    _ensureFirebaseReady();
    final user = _firebaseAuth.currentUser;
    final email = user?.email;
    if (user == null || email == null) {
      throw Exception('No Firebase user is signed in.');
    }
    try {
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on firebase_auth.FirebaseAuthException catch (error) {
      throw Exception(_firebaseErrorMessage(error));
    }
  }

  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    final user = User.fromJson(userData);
    await prefs.setInt('id', user.id);
    await prefs.setString('username', user.username);
    await prefs.setString('email', user.email);
    await prefs.setString('firstName', user.firstName);
    await prefs.setString('lastName', user.lastName);
    await prefs.setString('gender', user.gender);
    await prefs.setString('image', user.image);
    await prefs.setString('accessToken', user.accessToken);
    await prefs.setString('refreshToken', user.refreshToken);
    await prefs.setString('loginType', user.provider);
    await prefs.setString('contactNo', user.contactNo);
    if (user.age != null) await prefs.setInt('age', user.age!);
    final token = userData['token'] ?? user.accessToken;
    await prefs.setString('token', '$token');
  }

  Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final type = await _getLoginType(prefs: prefs);
    if (type == LoginType.firebase && _firebaseIsReady) {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser != null) {
        await _saveFirebaseUser(firebaseUser, prefs: prefs);
      }
    }
    return {
      'id': prefs.getInt('id') ?? 0,
      'username': prefs.getString('username') ?? '',
      'email': prefs.getString('email') ?? '',
      'firstName': prefs.getString('firstName') ?? '',
      'lastName': prefs.getString('lastName') ?? '',
      'gender': prefs.getString('gender') ?? '',
      'image': prefs.getString('image') ?? '',
      'accessToken': prefs.getString('accessToken') ?? '',
      'refreshToken': prefs.getString('refreshToken') ?? '',
      'token': prefs.getString('token') ?? prefs.getString('accessToken') ?? '',
      'age': prefs.getInt('age'),
      'contactNo': prefs.getString('contactNo') ?? '',
      'provider': type.name,
    };
  }

  Future<User> getUser() async => User.fromJson(await getUserData());

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final type = await _getLoginType(prefs: prefs);
    if (type == LoginType.firebase) {
      return _firebaseIsReady && _firebaseAuth.currentUser != null;
    }
    final token = prefs.getString('accessToken') ?? prefs.getString('token');
    return token != null && token.isNotEmpty;
  }

  Future<LoginType> _getLoginType({SharedPreferences? prefs}) async {
    final storage = prefs ?? await SharedPreferences.getInstance();
    return storage.getString('loginType') == LoginType.firebase.name
        ? LoginType.firebase
        : LoginType.dummyJson;
  }

  bool get _firebaseIsReady => Firebase.apps.isNotEmpty;

  void _ensureFirebaseReady() {
    if (!_firebaseIsReady) {
      throw Exception(
          'Firebase is not initialized. Start the app through main().');
    }
  }

  Future<void> _saveFirebaseUser(
    firebase_auth.User user, {
    SharedPreferences? prefs,
  }) async {
    final storage = prefs ?? await SharedPreferences.getInstance();
    final displayParts = (user.displayName ?? '').trim().split(RegExp(r'\s+'));
    final storedFirstName = storage.getString('firstName') ?? '';
    final storedLastName = storage.getString('lastName') ?? '';
    await storage.setInt('id', 0);
    await storage.setString('email', user.email ?? '');
    await storage.setString(
      'firstName',
      storedFirstName.isNotEmpty
          ? storedFirstName
          : (displayParts.isNotEmpty ? displayParts.first : ''),
    );
    await storage.setString(
      'lastName',
      storedLastName.isNotEmpty
          ? storedLastName
          : (displayParts.length > 1 ? displayParts.sublist(1).join(' ') : ''),
    );
    await storage.setString('loginType', LoginType.firebase.name);
  }

  void _validateSignup({
    required String firstName,
    required String lastName,
    required int age,
    required String contactNo,
    required String username,
    required String email,
    required String password,
  }) {
    if ([firstName, lastName, contactNo, username, email]
        .any((value) => value.trim().isEmpty)) {
      throw const FormatException('All signup fields are required.');
    }
    if (age <= 0 || age > 120) {
      throw const FormatException('Enter a valid age.');
    }
    if (!RegExp(r'^\+?[0-9 ()-]{7,20}$').hasMatch(contactNo.trim())) {
      throw const FormatException('Enter a valid contact number.');
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.trim())) {
      throw const FormatException('Enter a valid email address.');
    }
    if (password.length < 6) {
      throw const FormatException('Password must be at least 6 characters.');
    }
  }

  String _firebaseErrorMessage(firebase_auth.FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'That email address is already registered.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'weak-password':
        return 'Choose a stronger password (at least 6 characters).';
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Invalid email or password.';
      case 'requires-recent-login':
        return 'Please sign in again before performing this account action.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      default:
        return error.message ?? 'Firebase authentication failed.';
    }
  }
}
