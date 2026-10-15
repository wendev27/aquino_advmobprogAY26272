import 'dart:async';

import 'package:flutter/foundation.dart';
import '../models/cart.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../services/commerce_storage_service.dart';

class CartProvider extends ChangeNotifier {
  final CommerceStorageService _storage;
  final List<CartProduct> _cartProducts = [];
  String? _accountKey;
  bool _isLoading = false;
  bool _hasLoaded = false;
  int _loadVersion = 0;
  bool _changedDuringLoad = false;

  CartProvider({CommerceStorageService? storage})
      : _storage = storage ?? CommerceStorageService();

  List<CartProduct> get cartProducts => List.unmodifiable(_cartProducts);

  bool get isLoading => _isLoading;

  int get itemCount =>
      _cartProducts.fold(0, (sum, item) => sum + item.quantity);

  double get total {
    return _cartProducts.fold(
      0.0,
      (sum, product) => sum + (product.price * product.quantity),
    );
  }

  /// Loads the cart belonging to the currently signed-in account.
  Future<void> initializeForAccount(String accountKey) async {
    if (_accountKey == accountKey && _hasLoaded) return;

    _accountKey = accountKey;
    _isLoading = true;
    _hasLoaded = false;
    _changedDuringLoad = false;
    final version = ++_loadVersion;
    _cartProducts.clear();
    notifyListeners();

    final savedProducts = await _storage.loadCart(accountKey);
    if (version != _loadVersion || _accountKey != accountKey) return;

    if (_changedDuringLoad) {
      for (final savedProduct in savedProducts) {
        final currentIndex = _cartProducts
            .indexWhere((product) => product.id == savedProduct.id);
        if (currentIndex < 0) {
          _cartProducts.add(savedProduct);
        } else {
          _cartProducts[currentIndex] = _copyWithQuantity(
            _cartProducts[currentIndex],
            _cartProducts[currentIndex].quantity + savedProduct.quantity,
          );
        }
      }
    } else {
      _cartProducts
        ..clear()
        ..addAll(savedProducts);
    }
    _isLoading = false;
    _hasLoaded = true;
    notifyListeners();
    _persist();
  }

  void addToCart(Product product) {
    final existingIndex = _cartProducts.indexWhere((p) => p.id == product.id);
    if (existingIndex >= 0) {
      _cartProducts[existingIndex] = _copyWithQuantity(
        _cartProducts[existingIndex],
        _cartProducts[existingIndex].quantity + 1,
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
    _changedDuringLoad = true;
    notifyListeners();
    _persist();
  }

  void removeFromCart(int productId) {
    _cartProducts.removeWhere((p) => p.id == productId);
    _changedDuringLoad = true;
    notifyListeners();
    _persist();
  }

  void clearCart() {
    _cartProducts.clear();
    _changedDuringLoad = true;
    notifyListeners();
    _persist();
  }

  void updateQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }
    final index = _cartProducts.indexWhere((p) => p.id == productId);
    if (index >= 0) {
      _cartProducts[index] = _copyWithQuantity(_cartProducts[index], quantity);
      _changedDuringLoad = true;
      notifyListeners();
      _persist();
    }
  }

  Future<PurchaseOrder> checkout() async {
    if (_accountKey == null || !_hasLoaded) {
      throw StateError('Your cart is still loading. Please try again.');
    }
    if (_cartProducts.isEmpty) {
      throw StateError('Your cart is empty.');
    }

    final order = PurchaseOrder(
      id: 'order_${DateTime.now().microsecondsSinceEpoch}',
      products: List<CartProduct>.from(_cartProducts),
      total: total,
      createdAt: DateTime.now(),
    );
    await _storage.saveOrder(_accountKey!, order);
    _cartProducts.clear();
    _changedDuringLoad = false;
    notifyListeners();
    await _storage.saveCart(_accountKey!, _cartProducts);
    return order;
  }

  Future<List<PurchaseOrder>> loadOrderHistory() {
    final accountKey = _accountKey;
    if (accountKey == null) return Future.value([]);
    return _storage.loadOrders(accountKey);
  }

  CartProduct _copyWithQuantity(CartProduct product, int quantity) {
    return CartProduct(
      id: product.id,
      title: product.title,
      price: product.price,
      quantity: quantity,
      discountPercentage: product.discountPercentage,
      thumbnail: product.thumbnail,
    );
  }

  void _persist() {
    if (_accountKey == null || !_hasLoaded) return;
    unawaited(_storage.saveCart(_accountKey!, _cartProducts));
  }
}
