// lib/providers/product_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/firestore_service.dart';

class ProductProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();

  List<Product> _products      = [];
  List<Product> _searchResults = [];
  bool          _loading       = true;
  String        _selectedCategory = 'All';
  StreamSubscription<List<Product>>? _sub;

  List<Product> get products         => _products;
  List<Product> get searchResults    => _searchResults;
  bool          get loading          => _loading;
  String        get selectedCategory => _selectedCategory;

  List<Product> get featured   => _products.where((p) => p.isFeatured).toList();
  List<Product> get newArrivals => _products.where((p) => p.isNew).toList();

  List<Product> get filtered {
    if (_selectedCategory == 'All') return _products;
    return _products
        .where((p) => p.category == _selectedCategory)
        .toList();
  }

  static const List<String> categories = [
    'All', 'Men', 'Women', 'Accessories', 'Footwear', 'Outerwear',
  ];

  // ── Start streaming products ───────────────────────────────────────────────
  void init() {
    _sub?.cancel();
    _sub = _service.productsStream().listen((products) {
      _products = products;
      _loading  = false;
      notifyListeners();
    });
  }

  // ── Category filter ────────────────────────────────────────────────────────
  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // ── Search ─────────────────────────────────────────────────────────────────
  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }
    _searchResults = await _service.searchProducts(query);
    notifyListeners();
  }

  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
