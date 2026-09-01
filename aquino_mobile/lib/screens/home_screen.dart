import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../widgets/product_card.dart';
import 'product_details_screen.dart';

// Purpose: Display the home screen with product list and search
// Responsibilities: Show products from API, handle search, and navigate to details
// Why this class exists: To provide the main screen where users browse products

class HomeScreen extends StatefulWidget {
  // Constructor for HomeScreen
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Service to fetch products from API
  final ProductService _productService = ProductService();
  
  // List of products to display
  List<Product> _products = [];
  
  // Loading state
  bool _isLoading = false;
  
  // Error message
  String? _errorMessage;
  
  // Search query
  String _searchQuery = '';
  
  // Search text controller
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load products when screen initializes
    _loadProducts();
  }

  // Load products from API
  // Why this exists: To fetch product data when the screen loads
  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      List<Product> products;
      
      // The search query is checked here before making the API call.
      // If the user typed a keyword, the app uses the server-side search endpoint;
      // otherwise it loads the full catalog from the products endpoint.
      if (_searchQuery.isNotEmpty) {
        products = await _productService.searchProducts(_searchQuery);
      } else {
        products = await _productService.fetchProducts();
      }
      
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Handle search submission
  // Inputs: Search query string
  // Why this exists: To trigger API search when user submits search
  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
    _loadProducts();
  }

  // Clear search and reload all products
  // Why this exists: To reset search and show all products
  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
    _loadProducts();
  }

  @override
  void dispose() {
    // Dispose controller when widget is removed
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProducts,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
              ),
              onSubmitted: _onSearch,
            ),
          ),
          // Product list or loading/error states
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  // Build the body content based on state
  // Outputs: Widget to display based on loading/error/data state
  // Why this exists: To separate body building logic for cleaner code
  Widget _buildBody() {
    // Show loading indicator
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    // Show error message
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProducts,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    // Show empty state
    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isEmpty ? Icons.inventory_2_outlined : Icons.search_off,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty ? 'No products available' : 'No products found',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }
    
    // Show product list using ListView.builder
    return ListView.builder(
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return ProductCard(
          product: product,
          onTap: () {
            // Navigate to product details
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailsScreen(
                  product: product,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
