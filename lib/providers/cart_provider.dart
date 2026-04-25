// lib/providers/cart_provider.dart
import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get shipping => _items.isEmpty ? 0.0 : 9.99;

  double get total => subtotal + shipping;

  bool containsProduct(String productId) =>
      _items.any((item) => item.product.id == productId);

  /// Add a product to cart 
  void addItem(Product product, {String? size, String? color}) {
    final selectedSize  = size  ?? product.sizes.first;
    final selectedColor = color ?? product.colors.first;

    final existingIndex = _items.indexWhere(
      (i) =>
          i.product.id == product.id &&
          i.selectedSize == selectedSize &&
          i.selectedColor == selectedColor,
    );

    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItem(
        product: product,
        selectedSize: selectedSize,
        selectedColor: selectedColor,
      ));
    }
    notifyListeners();
  }

  void removeItem(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void increaseQuantity(int index) {
    _items[index].quantity++;
    notifyListeners();
  }

  void decreaseQuantity(int index) {
    if (_items[index].quantity > 1) {
      _items[index].quantity--;
    } else {
      _items.removeAt(index);
    }
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
