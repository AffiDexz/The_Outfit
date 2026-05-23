// lib/models/product_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String brand;
  final String category;
  final double price;
  final double? originalPrice;
  final String imageUrl;
  final String description;
  final double rating;
  final int reviewCount;
  final List<String> sizes;
  final List<String> colors;
  final bool isNew;
  final bool isFeatured;

  const Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.price,
    this.originalPrice,
    required this.imageUrl,
    required this.description,
    required this.rating,
    required this.reviewCount,
    required this.sizes,
    required this.colors,
    this.isNew      = false,
    this.isFeatured = false,
  });

  double get discountPercent {
    if (originalPrice == null || originalPrice! <= price) return 0;
    return ((originalPrice! - price) / originalPrice! * 100).roundToDouble();
  }

  // ── Firestore deserialization ──────────────────────────────────────────────
  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id:            doc.id,
      name:          data['name']          ?? '',
      brand:         data['brand']         ?? 'The Outfit',
      category:      data['category']      ?? '',
      price:         (data['price']        ?? 0).toDouble(),
      originalPrice: data['originalPrice'] != null
          ? (data['originalPrice']).toDouble()
          : null,
      imageUrl:      data['imageUrl']      ?? '',
      description:   data['description']   ?? '',
      rating:        (data['rating']       ?? 0).toDouble(),
      reviewCount:   data['reviewCount']   ?? 0,
      sizes:         List<String>.from(data['sizes']  ?? []),
      colors:        List<String>.from(data['colors'] ?? []),
      isNew:         data['isNew']         ?? false,
      isFeatured:    data['isFeatured']    ?? false,
    );
  }

  // ── Firestore serialization ────────────────────────────────────────────────
  Map<String, dynamic> toFirestore() => {
        'name':          name,
        'brand':         brand,
        'category':      category,
        'price':         price,
        'originalPrice': originalPrice,
        'imageUrl':      imageUrl,
        'description':   description,
        'rating':        rating,
        'reviewCount':   reviewCount,
        'sizes':         sizes,
        'colors':        colors,
        'isNew':         isNew,
        'isFeatured':    isFeatured,
      };
}
