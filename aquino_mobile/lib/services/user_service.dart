import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../models/user.dart';

// Purpose: Handle all API calls related to user authentication using DummyJSON
// Responsibilities: Login, logout, save/retrieve user data from SharedPreferences
// Why this class exists: To separate authentication logic from UI code

class UserService {
  // Login user with username and password
  // Inputs: Username and password
  // Outputs: Map containing user data and tokens
  // Throws: Exception if API call fails
  Future<Map<String, dynamic>> loginUser(String username, String password) async {
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
        final data = jsonDecode(response.body);
        await saveUserData(data);
        return data;
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // Save user data to SharedPreferences
  // Inputs: Map containing user data from API
  // Why this exists: To persist user session across app restarts
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    // The API returns a JSON map. We convert it into a User model so the
    // app can store the most important session fields in a consistent way.
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

    // Handle both 'token' and 'accessToken' for compatibility
    if (userData.containsKey('token')) {
      await prefs.setString('token', userData['token'] ?? '');
    } else if (user.accessToken.isNotEmpty) {
      await prefs.setString('token', user.accessToken);
    }
  }

  // Retrieve raw user data from SharedPreferences as a Map
  // Outputs: Map containing user data
  // Why this exists: To access stored user data
  Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();

    // This reads the saved token and profile data back from local storage so the
    // app can recreate the logged-in user state after a restart.
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
    };
  }

  // Retrieve a User model built from SharedPreferences
  // Outputs: User object
  // Why this exists: To provide type-safe user data access
  Future<User> getUser() async {
    final userData = await getUserData();
    return User.fromJson(userData);
  }

  // Check if user is logged in
  // Outputs: Boolean indicating login status
  // Why this exists: To determine if user needs to login
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    // The splash screen checks this before deciding whether to show the home flow
    // or send the user back to sign in.
    final token = prefs.getString('accessToken') ?? prefs.getString('token');
    return token != null && token.isNotEmpty;
  }

  // Logout and clear user data
  // Why this exists: To end user session
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      throw Exception('Failed to log out: $e');
    }
  }
}
