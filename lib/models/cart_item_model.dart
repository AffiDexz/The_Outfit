// lib/models/cart_item_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'product_model.dart';

class CartItem {
  final String firestoreId; // composite key used as Firestore doc ID
  final Product product;
  int quantity;
  String selectedSize;
  String selectedColor;

  CartItem({
    this.firestoreId = '',
    required this.product,
    this.quantity      = 1,
    required this.selectedSize,
    required this.selectedColor,
  });

  double get totalPrice => product.price * quantity;

  // Key used as Firestore document ID
  static String buildId(String productId, String size, String color) =>
      '${productId}_${size}_$color';

  // ── Firestore deserialization ──────────────────────────────────────────────
  factory CartItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final product = Product(
      id:           data['productId']    ?? doc.id,
      name:         data['name']         ?? '',
      brand:        data['brand']        ?? 'The Outfit',
      category:     data['category']     ?? '',
      price:        (data['price']       ?? 0).toDouble(),
      originalPrice: data['originalPrice'] != null
          ? (data['originalPrice']).toDouble()
          : null,
      imageUrl:     data['imageUrl']     ?? '',
      description:  data['description']  ?? '',
      rating:       (data['rating']      ?? 0).toDouble(),
      reviewCount:  data['reviewCount']  ?? 0,
      sizes:        List<String>.from(data['sizes']  ?? []),
      colors:       List<String>.from(data['colors'] ?? []),
    );

    return CartItem(
      firestoreId:   doc.id,
      product:       product,
      quantity:      data['quantity']      ?? 1,
      selectedSize:  data['selectedSize']  ?? '',
      selectedColor: data['selectedColor'] ?? '',
    );
  }

  // ── Firestore serialization ────────────────────────────────────────────────
  Map<String, dynamic> toFirestore() => {
        'productId':     product.id,
        'name':          product.name,
        'brand':         product.brand,
        'category':      product.category,
        'price':         product.price,
        'originalPrice': product.originalPrice,
        'imageUrl':      product.imageUrl,
        'description':   product.description,
        'rating':        product.rating,
        'reviewCount':   product.reviewCount,
        'sizes':         product.sizes,
        'colors':        product.colors,
        'quantity':      quantity,
        'selectedSize':  selectedSize,
        'selectedColor': selectedColor,
        'addedAt':       FieldValue.serverTimestamp(),
      };

  // Compact map for embedding inside an order document
  Map<String, dynamic> toOrderMap() => {
        'productId':     product.id,
        'name':          product.name,
        'price':         product.price,
        'imageUrl':      product.imageUrl,
        'selectedSize':  selectedSize,
        'selectedColor': selectedColor,
        'quantity':      quantity,
        'totalPrice':    totalPrice,
      };
}
