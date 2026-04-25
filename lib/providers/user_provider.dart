// lib/providers/user_provider.dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/order_model.dart';
import '../models/cart_item_model.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  final List<OrderModel> _orders = [];
  int _reviewCount = 0; 

  // ── Getters ──────────────────────────────────────────────────────────────────
  UserModel? get user => _user;
  bool get isLoggedIn => _user != null;
  List<OrderModel> get orders => List.unmodifiable(_orders);
  int get orderCount => _orders.length;
  int get reviewCount => _reviewCount;

  // ── Auth-like actions ─────────────────────────────────────────────────────────
  /// Called from RegisterScreen / LoginScreen
  void login({
    required String fullName,
    required String email,
    String phone = '',
    String address = '',
    String city = '',
    String zip = '',
  }) {
    _user = UserModel(
      fullName: fullName,
      email:    email,
      phone:    phone,
      address:  address,
      city:     city,
      zip:      zip,
    );
    notifyListeners();
  }

  void logout() {
    _user = null;
    _orders.clear();
    _reviewCount = 0;
    notifyListeners();
  }

  // ── Profile update ────────────────────────────────────────────────────────────
  void updateProfile({
    String? fullName,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? zip,
  }) {
    if (_user == null) return;
    _user = _user!.copyWith(
      fullName: fullName,
      email:    email,
      phone:    phone,
      address:  address,
      city:     city,
      zip:      zip,
    );
    notifyListeners();
  }

  // ── Orders ────────────────────────────────────────────────────────────────────
  void placeOrder({
    required List<CartItem> items,
    required double total,
    required String deliveryAddress,
  }) {
    final order = OrderModel(
      id:              'ORD-${DateTime.now().millisecondsSinceEpoch}',
      items:           List.from(items),
      total:           total,
      deliveryAddress: deliveryAddress,
      placedAt:        DateTime.now(),
      status:          OrderStatus.processing,
    );
    _orders.insert(0, order); // newest first
    notifyListeners();
  }

  void addReview() {
    _reviewCount++;
    notifyListeners();
  }
}