import 'package:flutter/material.dart';
import '../models/cart.dart';
import '../services/cart_service.dart';
import '../services/product_service.dart';
import '../models/product.dart';

class CartScreen extends StatefulWidget {
  final int userId;

  const CartScreen({super.key, required this.userId});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();
  final ProductService _productService = ProductService();
  Future<Cart?>? _cartFuture;

  @override
  void initState() {
    super.initState();
    _cartFuture = _cartService.getCartByUserId(widget.userId);
  }

  Future<void> _refreshCart() async {
    setState(() {
      _cartFuture = _cartService.getCartByUserId(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
      ),
      body: FutureBuilder<Cart?>(
        future: _cartFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Your cart is empty'));
          }

          final cart = snapshot.data!;
          if (cart.products.isEmpty) {
            return const Center(child: Text('Your cart is empty'));
          }

          return RefreshIndicator(
            onRefresh: _refreshCart,
            child: ListView.builder(
              itemCount: cart.products.length,
              itemBuilder: (context, index) {
                final product = cart.products[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: Image.network(
                      product.thumbnail,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.image_not_supported);
                      },
                    ),
                    title: Text(product.title),
                    subtitle: Text(
                      '\$${product.price.toStringAsFixed(2)} x ${product.quantity}',
                    ),
                    trailing: Text(
                      '\$${(product.price * product.quantity).toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () async {
                      try {
                        final fullProduct = await _productService.fetchProductById(product.id);
                        if (mounted) {
                          Navigator.pushNamed(
                            context,
                            '/product-details',
                            arguments: fullProduct,
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to load product: $e')),
                          );
                        }
                      }
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: cartTotalWidget(),
    );
  }

  Widget cartTotalWidget() {
    return FutureBuilder<Cart?>(
      future: _cartFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox.shrink();
        }
        final cart = snapshot.data!;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total:', style: TextStyle(fontSize: 16)),
                  Text(
                    '\$${cart.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Checkout feature coming soon!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Checkout'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
