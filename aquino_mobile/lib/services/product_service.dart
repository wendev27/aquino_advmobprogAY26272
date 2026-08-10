import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/product.dart';

// Purpose: Handle all API calls related to products using DummyJSON
// Responsibilities: Fetch products, search products, and fetch single product
// Why this class exists: To separate API logic from UI code and make it reusable

class ProductService {
  // Fetch all products from the API
  // Outputs: List of Product objects
  // Throws: Exception if API call fails
  // Why this exists: To retrieve product data from the remote API
  Future<List<Product>> fetchProducts() async {
    try {
      // Make HTTP GET request to the products endpoint
      final response = await http.get(
        Uri.parse(productsUrl),
      );

      // Check if request was successful (status code 200)
      if (response.statusCode == 200) {
        // Parse the JSON response - DummyJSON returns { products: [...] }
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> productsList = jsonData['products'] as List<dynamic>;
        
        // Convert JSON list to List<Product>
        return productsList
            .map((jsonItem) => Product.fromJson(jsonItem as Map<String, dynamic>))
            .toList();
      } else {
        // Throw exception for unsuccessful status code
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      // Throw exception for any error during API call
      throw Exception('Error fetching products: $e');
    }
  }

  // Search products by query using the API
  // Inputs: Search query string
  // Outputs: List of Product objects matching the search
  // Throws: Exception if API call fails
  // Why this exists: To search products on the server side
  Future<List<Product>> searchProducts(String query) async {
    try {
      // Make HTTP GET request to search endpoint with query parameter
      final response = await http.get(
        Uri.parse('$searchUrl?q=$query'),
      );

      // Check if request was successful
      if (response.statusCode == 200) {
        // Parse the JSON response - DummyJSON returns { products: [...] }
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> productsList = jsonData['products'] as List<dynamic>;
        
        // Convert JSON list to List<Product>
        return productsList
            .map((jsonItem) => Product.fromJson(jsonItem as Map<String, dynamic>))
            .toList();
      } else {
        // Throw exception for unsuccessful status code
        throw Exception('Failed to search products: ${response.statusCode}');
      }
    } catch (e) {
      // Throw exception for any error during API call
      throw Exception('Error searching products: $e');
    }
  }

  // Fetch a single product by ID
  // Inputs: Product ID
  // Outputs: Product object
  // Throws: Exception if API call fails
  // Why this exists: To retrieve details for a specific product
  Future<Product> fetchProductById(int id) async {
    try {
      // Make HTTP GET request to specific product endpoint
      final response = await http.get(
        Uri.parse('$productsUrl/$id'),
      );

      // Check if request was successful
      if (response.statusCode == 200) {
        // Parse the JSON response
        final Map<String, dynamic> jsonData = json.decode(response.body);
        
        // Convert JSON to Product object
        return Product.fromJson(jsonData);
      } else {
        // Throw exception for unsuccessful status code
        throw Exception('Failed to load product: ${response.statusCode}');
      }
    } catch (e) {
      // Throw exception for any error during API call
      throw Exception('Error fetching product: $e');
    }
  }
}
