import 'package:flutter/material.dart';
import '../models/product.dart';

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
                  // Add to cart button (placeholder)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Show snackbar as feedback
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Added ${product.title} to cart'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
