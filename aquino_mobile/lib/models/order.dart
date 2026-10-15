import 'cart.dart';

class PurchaseOrder {
  final String id;
  final List<CartProduct> products;
  final double total;
  final DateTime createdAt;
  final String status;

  PurchaseOrder({
    required this.id,
    required this.products,
    required this.total,
    required this.createdAt,
    this.status = 'completed',
  });

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) {
    final rawProducts = json['products'];
    final products = rawProducts is List
        ? rawProducts
            .map((item) => CartProduct.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ))
            .toList()
        : <CartProduct>[];
    final rawCreatedAt = json['createdAt'];

    return PurchaseOrder(
      id: '${json['id'] ?? ''}',
      products: products,
      total: (json['total'] as num?)?.toDouble() ?? 0,
      createdAt: rawCreatedAt is DateTime
          ? rawCreatedAt
          : DateTime.tryParse('$rawCreatedAt') ?? DateTime.now(),
      status: '${json['status'] ?? 'completed'}',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'products': products.map((product) => product.toJson()).toList(),
      'total': total,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
    };
  }
}
