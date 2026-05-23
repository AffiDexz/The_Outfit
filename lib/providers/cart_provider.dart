// lib/providers/cart_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import '../services/firestore_service.dart';

class CartProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();

  List<CartItem> _items = [];
  StreamSubscription<List<CartItem>>? _sub;
  String? _uid;

  List<CartItem> get items      => List.unmodifiable(_items);
  int            get itemCount  => _items.fold(0, (s, i) => s + i.quantity);
  double         get subtotal   => _items.fold(0.0, (s, i) => s + i.totalPrice);
  double         get shipping   => _items.isEmpty ? 0.0 : 9.99;
  double         get total      => subtotal + shipping;

  // ── Called after login ─────────────────────────────────────────────────────
  void init(String uid) {
    _uid = uid;
    _sub?.cancel();
    _sub = _service.cartStream(uid).listen((items) {
      _items = items;
      notifyListeners();
    });
  }

  // ── Called on logout ───────────────────────────────────────────────────────
  void clear() {
    _sub?.cancel();
    _sub   = null;
    _uid   = null;
    _items = [];
    notifyListeners();
  }

  // ── Add item ───────────────────────────────────────────────────────────────
  Future<void> addItem(
    Product product, {
    String? size,
    String? color,
  }) async {
    if (_uid == null) return;
    final item = CartItem(
      product:       product,
      selectedSize:  size  ?? product.sizes.first,
      selectedColor: color ?? product.colors.first,
    );
    await _service.addToCart(_uid!, item);
  }

  // ── Remove item ────────────────────────────────────────────────────────────
  Future<void> removeItem(int index) async {
    if (_uid == null || index >= _items.length) return;
    final docId = _items[index].firestoreId;
    await _service.removeCartItem(_uid!, docId);
  }

  // ── Increase quantity ──────────────────────────────────────────────────────
  Future<void> increaseQuantity(int index) async {
    if (_uid == null || index >= _items.length) return;
    final item = _items[index];
    await _service.updateCartQuantity(
        _uid!, item.firestoreId, item.quantity + 1);
  }

  // ── Decrease quantity / remove if 0 ───────────────────────────────────────
  Future<void> decreaseQuantity(int index) async {
    if (_uid == null || index >= _items.length) return;
    final item = _items[index];
    await _service.updateCartQuantity(
        _uid!, item.firestoreId, item.quantity - 1);
  }

  // ── Clear all ──────────────────────────────────────────────────────────────
  Future<void> clearCart() async {
    if (_uid == null) return;
    await _service.clearCart(_uid!);
  }

  bool containsProduct(String productId) =>
      _items.any((i) => i.product.id == productId);

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
