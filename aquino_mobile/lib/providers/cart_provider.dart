import 'package:flutter/foundation.dart';
import '../models/cart.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  final List<CartProduct> _cartProducts = [];

  List<CartProduct> get cartProducts => List.unmodifiable(_cartProducts);

  int get itemCount => _cartProducts.fold(0, (sum, item) => sum + item.quantity);

  double get total {
    return _cartProducts.fold(
      0.0,
      (sum, product) => sum + (product.price * product.quantity),
    );
  }

  void addToCart(Product product) {
    final existingIndex = _cartProducts.indexWhere((p) => p.id == product.id);
    if (existingIndex >= 0) {
      _cartProducts[existingIndex] = CartProduct(
        id: _cartProducts[existingIndex].id,
        title: _cartProducts[existingIndex].title,
        price: _cartProducts[existingIndex].price,
        quantity: _cartProducts[existingIndex].quantity + 1,
        discountPercentage: _cartProducts[existingIndex].discountPercentage,
        thumbnail: _cartProducts[existingIndex].thumbnail,
      );
    } else {
      _cartProducts.add(CartProduct(
        id: product.id,
        title: product.title,
        price: product.price,
        quantity: 1,
        discountPercentage: product.discountPercentage,
        thumbnail: product.thumbnail,
      ));
    }
    notifyListeners();
  }

  void removeFromCart(int productId) {
    _cartProducts.removeWhere((p) => p.id == productId);
    notifyListeners();
  }

  void clearCart() {
    _cartProducts.clear();
    notifyListeners();
  }

  void updateQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }
    final index = _cartProducts.indexWhere((p) => p.id == productId);
    if (index >= 0) {
      _cartProducts[index] = CartProduct(
        id: _cartProducts[index].id,
        title: _cartProducts[index].title,
        price: _cartProducts[index].price,
        quantity: quantity,
        discountPercentage: _cartProducts[index].discountPercentage,
        thumbnail: _cartProducts[index].thumbnail,
      );
      notifyListeners();
    }
  }
}
