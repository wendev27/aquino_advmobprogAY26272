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
  static const _activeSessionKeys = [
    'id',
    'username',
    'email',
    'firstName',
    'lastName',
    'gender',
    'image',
    'accessToken',
    'refreshToken',
    'token',
    'age',
    'contactNo',
    'uid',
    'loginType',
  ];

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
        if (_firebaseIsReady && _firebaseAuth.currentUser != null) {
          await _firebaseAuth.signOut();
        }
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
      await _clearActiveSession(prefs);
      await prefs.setString('loginType', LoginType.firebase.name);
      await _writeFirebaseProfile(
        user,
        {
          'username': username.trim(),
          'firstName': firstName.trim(),
          'lastName': lastName.trim(),
          'age': age,
          'contactNo': contactNo.trim(),
        },
        prefs: prefs,
      );
      await _saveFirebaseUser(user, prefs: prefs);
      return getUserData();
    } on firebase_auth.FirebaseAuthException catch (error) {
      throw Exception(_firebaseErrorMessage(error));
    }
  }

  Future<void> signOut({LoginType? loginType}) async {
    if (_firebaseIsReady && _firebaseAuth.currentUser != null) {
      await _firebaseAuth.signOut();
    }
    final prefs = await SharedPreferences.getInstance();
    await _clearActiveSession(prefs);
  }

  Future<void> logout() => signOut();

  Future<void> updateUsername(String username) async {
    final value = username.trim();
    if (value.isEmpty) throw const FormatException('Username is required.');
    final type = await _getLoginType();
    final prefs = await SharedPreferences.getInstance();
    if (type == LoginType.firebase) {
      _ensureFirebaseReady();
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('No Firebase user is signed in.');
      }
      await user.updateDisplayName(value);
      await _writeFirebaseProfile(
        user,
        {
          'username': value,
          'firstName': prefs.getString('firstName') ?? '',
          'lastName': prefs.getString('lastName') ?? '',
          'age': prefs.getInt('age'),
          'contactNo': prefs.getString('contactNo') ?? '',
        },
        prefs: prefs,
      );
      await prefs.setString('username', value);
      return;
    }
    await prefs.setString('username', value);
  }

  Future<void> deleteAccount({String? currentPassword}) async {
    final type = await _getLoginType();
    if (type != LoginType.firebase) {
      throw Exception('DummyJSON does not support account deletion.');
    }
    if (currentPassword == null || currentPassword.isEmpty) {
      throw const FormatException('Current password is required.');
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
      await user.delete();
    } on firebase_auth.FirebaseAuthException catch (error) {
      if (error.code == 'wrong-password' ||
          error.code == 'invalid-credential') {
        throw Exception('Incorrect current password.');
      }
      throw Exception(_firebaseErrorMessage(error));
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_firebaseProfileKey(user.uid));
    await _clearActiveSession(prefs);
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
    await _clearActiveSession(prefs);
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
    await prefs.remove('uid');
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
    final profile = _readFirebaseProfile(storage, user.uid);
    final displayParts = (user.displayName ?? '').trim().split(RegExp(r'\s+'));
    final storedFirstName =
        '${profile?['firstName'] ?? storage.getString('firstName') ?? ''}';
    final storedLastName =
        '${profile?['lastName'] ?? storage.getString('lastName') ?? ''}';
    final storedUsername =
        '${profile?['username'] ?? storage.getString('username') ?? ''}';
    await storage.setInt('id', 0);
    await storage.setString('uid', user.uid);
    await storage.setString('email', user.email ?? '');
    await storage.setString('username', storedUsername);
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
    final age = profile?['age'];
    if (age is int) {
      await storage.setInt('age', age);
    } else {
      await storage.remove('age');
    }
    await storage.setString('contactNo', '${profile?['contactNo'] ?? ''}');
    await storage.setString('loginType', LoginType.firebase.name);
  }

  String _firebaseProfileKey(String uid) => 'firebase_profile_$uid';

  Map<String, dynamic>? _readFirebaseProfile(
    SharedPreferences prefs,
    String uid,
  ) {
    final raw = prefs.getString(_firebaseProfileKey(uid));
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic>
          ? decoded
          : Map<String, dynamic>.from(decoded as Map);
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeFirebaseProfile(
    firebase_auth.User user,
    Map<String, dynamic> values, {
    SharedPreferences? prefs,
  }) async {
    final storage = prefs ?? await SharedPreferences.getInstance();
    final profile =
        _readFirebaseProfile(storage, user.uid) ?? <String, dynamic>{};
    profile.addAll(values);
    profile['uid'] = user.uid;
    await storage.setString(_firebaseProfileKey(user.uid), jsonEncode(profile));
  }

  Future<void> _clearActiveSession(SharedPreferences prefs) async {
    for (final key in _activeSessionKeys) {
      await prefs.remove(key);
    }
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
