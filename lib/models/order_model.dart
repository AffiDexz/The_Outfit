// lib/models/order_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus { processing, shipped, delivered, cancelled }

class OrderModel {
  final String id;
  final String userId;
  final List<Map<String, dynamic>> items;
  final double total;
  final String deliveryAddress;
  final String paymentMethod;
  final DateTime placedAt;
  final OrderStatus status;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.total,
    required this.deliveryAddress,
    required this.paymentMethod,
    required this.placedAt,
    this.status = OrderStatus.processing,
  });

  String get statusLabel {
    switch (status) {
      case OrderStatus.processing: return 'Processing';
      case OrderStatus.shipped:    return 'Shipped';
      case OrderStatus.delivered:  return 'Delivered';
      case OrderStatus.cancelled:  return 'Cancelled';
    }
  }

  int get itemCount =>
      items.fold(0, (total, i) => total + ((i['quantity'] as int?) ?? 1));
  static OrderStatus _parseStatus(String? s) {
    switch (s) {
      case 'shipped':   return OrderStatus.shipped;
      case 'delivered': return OrderStatus.delivered;
      case 'cancelled': return OrderStatus.cancelled;
      default:          return OrderStatus.processing;
    }
  }

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id:              doc.id,
      userId:          data['userId']          ?? '',
      items:           List<Map<String, dynamic>>.from(data['items'] ?? []),
      total:           (data['total']          ?? 0).toDouble(),
      deliveryAddress: data['deliveryAddress'] ?? '',
      paymentMethod:   data['paymentMethod']   ?? '',
      placedAt:        (data['placedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status:          _parseStatus(data['status']),
    );
  }
}
