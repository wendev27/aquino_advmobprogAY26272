// Purpose: Represents a Product entity from the DummyJSON API
// Responsibilities: Store product data and provide JSON serialization
// Why this class exists: To type-safe represent product data instead of using dynamic

class Product {
  // Unique identifier for the product
  final int id;
  
  // Title/name of the product
  final String title;
  
  // Description of the product
  final String description;
  
  // Price of the product
  final double price;
  
  // Thumbnail image URL
  final String thumbnail;
  
  // Category of the product
  final String category;
  
  // Rating of the product
  final double rating;
  
  // Brand of the product
  final String brand;
  
  // Stock quantity
  final int stock;
  
  // Discount percentage
  final double discountPercentage;

  // Constructor for Product
  // Inputs: All required product fields
  // Why this exists: To create a Product instance with all necessary data
  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.thumbnail,
    required this.category,
    required this.rating,
    this.brand = '',
    this.stock = 0,
    this.discountPercentage = 0.0,
  });

  // Factory constructor to create Product from JSON
  // Inputs: Map<String, dynamic> containing product data from API
  // Outputs: Product instance
  // Why this exists: To parse API response into type-safe Product objects
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      thumbnail: json['thumbnail'] as String,
      category: json['category'] as String,
      rating: (json['rating'] as num).toDouble(),
      brand: json['brand'] ?? '',
      stock: json['stock'] ?? 0,
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // Convert Product to JSON
  // Outputs: Map<String, dynamic> representation of Product
  // Why this exists: To serialize Product for API requests or storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'thumbnail': thumbnail,
      'category': category,
      'rating': rating,
      'brand': brand,
      'stock': stock,
      'discountPercentage': discountPercentage,
    };
  }
}
