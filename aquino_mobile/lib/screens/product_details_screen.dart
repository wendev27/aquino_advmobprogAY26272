import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/product.dart';
import '../services/cart_service.dart';
import '../services/user_service.dart';

// Purpose: Display detailed information about a single product
// Responsibilities: Show product image, description, price, rating, and category
// Why this class exists: To provide a dedicated screen for viewing product details

class ProductDetailsScreen extends StatelessWidget {
  // The product to display
  final Product product;

  // Constructor for ProductDetailsScreen
  // Inputs: Product object to display
  // Why this exists: To create a details screen with product data
  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            SizedBox(
              width: double.infinity,
              height: 300,
              child: Image.network(
                product.thumbnail,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Show placeholder if image fails to load
                  return const Center(
                    child: Icon(Icons.image_not_supported, size: 100),
                  );
                },
              ),
            ),
            // Product information
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product category
                  Text(
                    product.category.toUpperCase(),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  // Product title
                  Text(
                    product.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  // Product price
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  // Product rating
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      const SizedBox(width: 8),
                      Text(
                        product.rating.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Brand and stock
                  Text(
                    '${product.brand} · Stock: ${product.stock}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 24),
                  // Divider
                  const Divider(),
                  const SizedBox(height: 16),
                  // Description label
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  // Product description
                  Text(
                    product.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  // Add to cart button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          // Lab 3 keeps the same model/service/screen pattern from Lab 2,
                          // but this action goes through CartService instead of doing the
                          // HTTP call directly in the screen.
                          final userService = UserService();
                          final userData = await userService.getUserData();
                          final userId = userData['id'] as int? ?? currentUserId;
                          
                          await CartService().addToCart(
                            userId,
                            [
                              {'id': product.id, 'quantity': 1},
                            ],
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Added to cart')),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to add: $e')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.amber,
                      ),
                      child: const Text('Add to Cart'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
