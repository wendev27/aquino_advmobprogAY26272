import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/cart.dart';

class CartService {
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
