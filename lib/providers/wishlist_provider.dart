// lib/providers/wishlist_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/firestore_service.dart';

class WishlistProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();

  List<Product> _items = [];
  StreamSubscription<List<Product>>? _sub;
  String? _uid;

  List<Product> get items => List.unmodifiable(_items);
  int           get count => _items.length;

  bool isWishlisted(String productId) =>
      _items.any((p) => p.id == productId);

  // ── Called after login ─────────────────────────────────────────────────────
  void init(String uid) {
    _uid = uid;
    _sub?.cancel();
    _sub = _service.wishlistStream(uid).listen((items) {
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

  // ── Toggle ─────────────────────────────────────────────────────────────────
  Future<void> toggle(Product product) async {
    if (_uid == null) return;
    if (isWishlisted(product.id)) {
      await _service.removeFromWishlist(_uid!, product.id);
    } else {
      await _service.addToWishlist(_uid!, product);
    }
  }

  // ── Remove ─────────────────────────────────────────────────────────────────
  Future<void> remove(String productId) async {
    if (_uid == null) return;
    await _service.removeFromWishlist(_uid!, productId);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
