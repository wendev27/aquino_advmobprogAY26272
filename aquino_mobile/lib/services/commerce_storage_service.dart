import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart.dart';
import '../models/order.dart';

/// Persists the active cart and completed purchases for one signed-in account.
///
/// Firebase accounts use Firestore as the primary store. SharedPreferences is
/// kept as a local fallback so cart and order history remain usable while
/// Firestore is unavailable. Demo DummyJSON accounts use the local store.
class CommerceStorageService {
  final FirebaseFirestore? _providedFirestore;
  final FirebaseAuth? _providedAuth;

  CommerceStorageService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _providedFirestore = firestore,
        _providedAuth = auth;

  Future<List<CartProduct>> loadCart(String accountKey) async {
    final local = await _loadLocalCart(accountKey);
    final uid = _firebaseUid(accountKey);
    final auth = _auth;
    final firestore = _firestore;
    if (uid == null || auth?.currentUser?.uid != uid || firestore == null) {
      return local;
    }

    try {
      final snapshot = await _cartDocument(firestore, uid).get();
      if (!snapshot.exists || snapshot.data() == null) return local;
      final data = snapshot.data()!;
      final rawItems = data['items'];
      if (rawItems is! List) return local;
      return rawItems
          .map((item) => CartProduct.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList();
    } catch (_) {
      return local;
    }
  }

  Future<void> saveCart(
    String accountKey,
    List<CartProduct> products,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _cartKey(accountKey),
      jsonEncode(products.map((product) => product.toJson()).toList()),
    );

    final uid = _firebaseUid(accountKey);
    final auth = _auth;
    final firestore = _firestore;
    if (uid == null || auth?.currentUser?.uid != uid || firestore == null) {
      return;
    }
    try {
      await _cartDocument(firestore, uid).set({
        'items': products.map((product) => product.toJson()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // The local copy remains available if Firestore is offline or denied.
    }
  }

  Future<List<PurchaseOrder>> loadOrders(String accountKey) async {
    final local = await _loadLocalOrders(accountKey);
    final uid = _firebaseUid(accountKey);
    final auth = _auth;
    final firestore = _firestore;
    if (uid == null || auth?.currentUser?.uid != uid || firestore == null) {
      return local;
    }

    try {
      final snapshot = await _ordersCollection(firestore, uid)
          .orderBy('createdAt', descending: true)
          .get();
      final remote = snapshot.docs.map((document) {
        final data = <String, dynamic>{
          ...document.data(),
          'id': document.id,
        };
        final timestamp = data['createdAt'];
        if (timestamp is Timestamp) {
          data['createdAt'] = timestamp.toDate().toIso8601String();
        }
        return PurchaseOrder.fromJson(data);
      }).toList();
      return remote.isEmpty ? local : remote;
    } catch (_) {
      return local;
    }
  }

  Future<void> saveOrder(String accountKey, PurchaseOrder order) async {
    final existing = await _loadLocalOrders(accountKey);
    final orders = [
      order,
      ...existing.where((savedOrder) => savedOrder.id != order.id),
    ];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _ordersKey(accountKey),
      jsonEncode(orders.map((savedOrder) => savedOrder.toJson()).toList()),
    );

    final uid = _firebaseUid(accountKey);
    final auth = _auth;
    final firestore = _firestore;
    if (uid == null || auth?.currentUser?.uid != uid || firestore == null) {
      return;
    }
    try {
      await _ordersCollection(firestore, uid).doc(order.id).set({
        'userId': uid,
        'products': order.products.map((product) => product.toJson()).toList(),
        'total': order.total,
        'status': order.status,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // The local order history remains available if the remote write fails.
    }
  }

  Future<List<CartProduct>> _loadLocalCart(String accountKey) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cartKey(accountKey));
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .map((item) => CartProduct.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<PurchaseOrder>> _loadLocalOrders(String accountKey) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_ordersKey(accountKey));
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .map((item) => PurchaseOrder.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList();
    } catch (_) {
      return [];
    }
  }

  DocumentReference<Map<String, dynamic>> _cartDocument(
    FirebaseFirestore firestore,
    String uid,
  ) =>
      firestore.collection('Users').doc(uid).collection('cart').doc('current');

  CollectionReference<Map<String, dynamic>> _ordersCollection(
    FirebaseFirestore firestore,
    String uid,
  ) =>
      firestore.collection('Users').doc(uid).collection('orders');

  FirebaseFirestore? get _firestore {
    if (_providedFirestore != null) return _providedFirestore;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  FirebaseAuth? get _auth {
    if (_providedAuth != null) return _providedAuth;
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  String? _firebaseUid(String accountKey) {
    const prefix = 'firebase_';
    if (!accountKey.startsWith(prefix)) return null;
    final uid = accountKey.substring(prefix.length);
    return uid.isEmpty ? null : uid;
  }

  String _cartKey(String accountKey) => 'saved_cart_$accountKey';

  String _ordersKey(String accountKey) => 'purchase_history_$accountKey';
}
