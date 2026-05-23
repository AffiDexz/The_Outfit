// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/cart_item_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ═══════════════════════════════════════════════════════════════════════════
  // PRODUCTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Stream of all products (live updates)
  Stream<List<Product>> productsStream() {
    return _db.collection('products').snapshots().map((snap) =>
        snap.docs.map((doc) => Product.fromFirestore(doc)).toList());
  }

  /// Fetch products by category
  Stream<List<Product>> productsByCategory(String category) {
    if (category == 'All') return productsStream();
    return _db
        .collection('products')
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => Product.fromFirestore(doc)).toList());
  }

  /// Search products by name
  Future<List<Product>> searchProducts(String query) async {
    final all = await _db.collection('products').get();
    final q   = query.toLowerCase();
    return all.docs
        .map((doc) => Product.fromFirestore(doc))
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q))
        .toList();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CART
  // ═══════════════════════════════════════════════════════════════════════════

  CollectionReference _cartItems(String uid) =>
      _db.collection('cart').doc(uid).collection('items');

  /// Stream cart items for user
  Stream<List<CartItem>> cartStream(String uid) {
    return _cartItems(uid).snapshots().map((snap) =>
        snap.docs.map((doc) => CartItem.fromFirestore(doc)).toList());
  }

  /// Add or update cart item
  Future<void> addToCart(String uid, CartItem item) async {
    // Use a composite key so same product in different size/color = different item
    final docId =
        '${item.product.id}_${item.selectedSize}_${item.selectedColor}';
    final ref = _cartItems(uid).doc(docId);
    final snap = await ref.get();

    if (snap.exists) {
      // Increase quantity
      await ref.update({'quantity': FieldValue.increment(1)});
    } else {
      await ref.set(item.toFirestore());
    }
  }

  /// Update quantity
  Future<void> updateCartQuantity(String uid, String docId, int qty) async {
    if (qty <= 0) {
      await _cartItems(uid).doc(docId).delete();
    } else {
      await _cartItems(uid).doc(docId).update({'quantity': qty});
    }
  }

  /// Remove cart item
  Future<void> removeCartItem(String uid, String docId) =>
      _cartItems(uid).doc(docId).delete();

  /// Clear entire cart
  Future<void> clearCart(String uid) async {
    final batch = _db.batch();
    final snap  = await _cartItems(uid).get();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // WISHLIST
  // ═══════════════════════════════════════════════════════════════════════════

  CollectionReference _wishlistItems(String uid) =>
      _db.collection('wishlist').doc(uid).collection('items');

  Stream<List<Product>> wishlistStream(String uid) {
    return _wishlistItems(uid).snapshots().map((snap) =>
        snap.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Product(
            id:           data['productId'] ?? doc.id,
            name:         data['name'] ?? '',
            brand:        data['brand'] ?? 'The Outfit',
            category:     data['category'] ?? '',
            price:        (data['price'] ?? 0).toDouble(),
            originalPrice: data['originalPrice'] != null
                ? (data['originalPrice']).toDouble()
                : null,
            imageUrl:     data['imageUrl'] ?? '',
            description:  data['description'] ?? '',
            rating:       (data['rating'] ?? 0).toDouble(),
            reviewCount:  data['reviewCount'] ?? 0,
            sizes:        List<String>.from(data['sizes'] ?? []),
            colors:       List<String>.from(data['colors'] ?? []),
          );
        }).toList());
  }

  Future<void> addToWishlist(String uid, Product p) async {
    await _wishlistItems(uid).doc(p.id).set({
      'productId':     p.id,
      'name':          p.name,
      'brand':         p.brand,
      'category':      p.category,
      'price':         p.price,
      'originalPrice': p.originalPrice,
      'imageUrl':      p.imageUrl,
      'description':   p.description,
      'rating':        p.rating,
      'reviewCount':   p.reviewCount,
      'sizes':         p.sizes,
      'colors':        p.colors,
      'addedAt':       FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeFromWishlist(String uid, String productId) =>
      _wishlistItems(uid).doc(productId).delete();

  // ═══════════════════════════════════════════════════════════════════════════
  // ORDERS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<String> placeOrder({
    required String uid,
    required List<CartItem> items,
    required double total,
    required String deliveryAddress,
    required String paymentMethod,
  }) async {
    final ref = await _db.collection('orders').add({
      'userId':          uid,
      'items':           items.map((i) => i.toOrderMap()).toList(),
      'total':           total,
      'deliveryAddress': deliveryAddress,
      'paymentMethod':   paymentMethod,
      'status':          'processing',
      'placedAt':        FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Stream<List<OrderModel>> ordersStream(String uid) {
    return _db
        .collection('orders')
        .where('userId', isEqualTo: uid)
        .orderBy('placedAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => OrderModel.fromFirestore(doc)).toList());
  }
}
