import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/cart.dart';

// Purpose: Handle all API calls related to carts using DummyJSON
// Responsibilities: Fetch carts, get cart by user, add to cart
// Why this class exists: To separate cart API logic from UI code

class CartService {
  // Fetch all carts from the API
  // Outputs: List of Cart objects
  // Throws: Exception if API call fails
  Future<List<Cart>> getAllCarts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/carts'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List cartsJson = data['carts'] ?? [];
        return cartsJson.map((json) => Cart.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load carts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching carts: $e');
    }
  }

  // Fetch cart for a specific user by their userId
  // Inputs: User ID
  // Outputs: Cart object or null if user has no cart
  // Throws: Exception if API call fails
  Future<Cart?> getCartByUserId(int userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/carts/user/$userId'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List cartsJson = data['carts'] ?? [];
        if (cartsJson.isEmpty) return null;
        return Cart.fromJson(cartsJson.first);
      } else {
        throw Exception('Failed to load cart for user $userId');
      }
    } catch (e) {
      throw Exception('Error fetching cart for user: $e');
    }
  }

  // Add products to cart for a specific user
  // Inputs: User ID and list of products (each with id and quantity)
  // Outputs: Updated Cart object
  // Throws: Exception if API call fails
  Future<Cart> addToCart(
    int userId,
    List<Map<String, dynamic>> products,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/carts/add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'products': products,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Cart.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to add to cart: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error adding to cart: $e');
    }
  }
}
