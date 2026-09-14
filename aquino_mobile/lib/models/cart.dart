class CartProduct {
  final int id;
  final String title;
  final double price;
  final int quantity;
  final double discountPercentage;
  final String thumbnail;

  CartProduct({
    required this.id,
    required this.title,
    required this.price,
    required this.quantity,
    required this.discountPercentage,
    required this.thumbnail,
  });

  factory CartProduct.fromJson(Map<String, dynamic> json) {
    return CartProduct(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 1,
      discountPercentage: (json['discountPercentage'] ?? 0).toDouble(),
      thumbnail: json['thumbnail'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'quantity': quantity,
      'discountPercentage': discountPercentage,
      'thumbnail': thumbnail,
    };
  }
}

class Cart {
  final int id;
  final List<CartProduct> products;
  final double total;
  final double discountedTotal;
  final int userId;
  final int totalProducts;
  final int totalQuantity;

  Cart({
    required this.id,
    required this.products,
    required this.total,
    required this.discountedTotal,
    required this.userId,
    required this.totalProducts,
    required this.totalQuantity,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    List<CartProduct> productsList = [];
    if (json['products'] != null) {
      productsList = (json['products'] as List)
          .map((item) => CartProduct.fromJson(item))
          .toList();
    }

    return Cart(
      id: json['id'] ?? 0,
      products: productsList,
      total: (json['total'] ?? 0).toDouble(),
      discountedTotal: (json['discountedTotal'] ?? 0).toDouble(),
      userId: json['userId'] ?? 0,
      totalProducts: json['totalProducts'] ?? 0,
      totalQuantity: json['totalQuantity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'products': products.map((p) => p.toJson()).toList(),
      'total': total,
      'discountedTotal': discountedTotal,
      'userId': userId,
      'totalProducts': totalProducts,
      'totalQuantity': totalQuantity,
    };
  }
}
