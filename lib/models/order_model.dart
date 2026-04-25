// lib/models/order_model.dart
import 'cart_item_model.dart';

enum OrderStatus { processing, shipped, delivered, cancelled }

class OrderModel {
  final String id;
  final List<CartItem> items;
  final double total;
  final String deliveryAddress;
  final DateTime placedAt;
  final OrderStatus status;

  const OrderModel({
    required this.id,
    required this.items,
    required this.total,
    required this.deliveryAddress,
    required this.placedAt,
    this.status = OrderStatus.processing,
  });

  String get statusLabel {
    switch (status) {
      case OrderStatus.processing:  return 'Processing';
      case OrderStatus.shipped:     return 'Shipped';
      case OrderStatus.delivered:   return 'Delivered';
      case OrderStatus.cancelled:   return 'Cancelled';
    }
  }

  int get itemCount => items.fold(0, (s, i) => s + i.quantity);
}