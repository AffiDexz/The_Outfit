// lib/services/firestore_seeder.dart
//
// Call FirestoreSeeder.seedProducts() ONCE from your app (e.g. a debug button).
// After products appear in Firestore Console, remove the call.
//
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

class FirestoreSeeder {
  static Future<void> seedProducts() async {
    final db = FirebaseFirestore.instance;
    final col = db.collection('products');

    // Check if already seeded
    final existing = await col.limit(1).get();
    if (existing.docs.isNotEmpty) {
      debugPrint('Products already seeded.');
      return;
    }

    final products = [
      // ── Men ────────────────────────────────────────────────────────────────
      {
        'name': 'Classic Slim Suit', 'brand': 'The Outfit', 'category': 'Men',
        'price': 189.99, 'originalPrice': 249.99,
        'imageUrl': 'assets/images/suit.jpg',
        'description': 'A meticulously crafted slim-fit suit in premium Italian wool. Perfect for formal occasions.',
        'rating': 4.8, 'reviewCount': 124,
        'sizes': ['S', 'M', 'L', 'XL', 'XXL'], 'colors': ['Charcoal', 'Navy', 'Black'],
        'isNew': false, 'isFeatured': true,
      },
      {
        'name': 'Urban Cargo Trousers', 'brand': 'The Outfit', 'category': 'Men',
        'price': 79.99, 'originalPrice': null,
        'imageUrl': 'assets/images/cargo.jpg',
        'description': 'Versatile cargo trousers with multiple utility pockets. Perfect for urban exploration.',
        'rating': 4.5, 'reviewCount': 89,
        'sizes': ['S', 'M', 'L', 'XL'], 'colors': ['Olive', 'Black', 'Khaki'],
        'isNew': true, 'isFeatured': false,
      },
      {
        'name': 'Merino Wool Turtleneck', 'brand': 'The Outfit', 'category': 'Men',
        'price': 110.00, 'originalPrice': 140.00,
        'imageUrl': 'assets/images/turtleneck.jpg',
        'description': 'Luxuriously soft merino wool turtleneck. Temperature regulating and incredibly comfortable.',
        'rating': 4.9, 'reviewCount': 210,
        'sizes': ['XS', 'S', 'M', 'L', 'XL'], 'colors': ['Cream', 'Camel', 'Charcoal'],
        'isNew': false, 'isFeatured': true,
      },
      {
        'name': 'Long Sleeve Shirt with Double Pockets', 'brand': 'The Outfit', 'category': 'Men',
        'price': 1100.00, 'originalPrice': 2000.00,
        'imageUrl': 'assets/images/Shirts.jpg',
        'description': 'Wash & Care - Hand wash with cold water, wash inside out.',
        'rating': 4.9, 'reviewCount': 210,
        'sizes': ['XS', 'S', 'M', 'L', 'XL'], 'colors': ['Cream', 'Camel', 'Charcoal'],
        'isNew': false, 'isFeatured': true,
      },
      // ── Women ──────────────────────────────────────────────────────────────
      {
        'name': 'Silk Wrap Dress', 'brand': 'The Outfit', 'category': 'Women',
        'price': 159.99, 'originalPrice': 210.00,
        'imageUrl': 'assets/images/Silk.jpg',
        'description': 'An elegant silk wrap dress that effortlessly transitions from day to evening.',
        'rating': 4.7, 'reviewCount': 156,
        'sizes': ['XS', 'S', 'M', 'L'], 'colors': ['Ivory', 'Blush', 'Midnight'],
        'isNew': false, 'isFeatured': true,
      },
      {
        'name': 'One Shoulder Puff Sleeve Dress', 'brand': 'The Outfit', 'category': 'Women',
        'price': 89.99, 'originalPrice': null,
        'imageUrl': 'assets/images/Puff.jpg',
        'description': 'An elegant one shoulder dress with puff sleeves for a modern silhouette.',
        'rating': 4.6, 'reviewCount': 98,
        'sizes': ['XS', 'S', 'M', 'L', 'XL'], 'colors': ['Black', 'Camel', 'White'],
        'isNew': true, 'isFeatured': false,
      },
      {
        'name': 'Cashmere Knit Cardigan', 'brand': 'The Outfit', 'category': 'Women',
        'price': 195.00, 'originalPrice': 250.00,
        'imageUrl': 'assets/images/Cardigan.jpg',
        'description': 'An exceptionally soft cashmere cardigan with a relaxed silhouette.',
        'rating': 4.9, 'reviewCount': 302,
        'sizes': ['XS', 'S', 'M', 'L'], 'colors': ['Oatmeal', 'Sage', 'Dusty Rose'],
        'isNew': false, 'isFeatured': true,
      },
      {
        'name': 'Linen Look Bow Pocket Waistcoat', 'brand': 'The Outfit', 'category': 'Women',
        'price': 195.00, 'originalPrice': 250.00,
        'imageUrl': 'assets/images/Linen.jpg',
        'description': 'Chic Linen Look Bow Pocket Waistcoat for a perfect blend of sophistication and modern style.',
        'rating': 4.9, 'reviewCount': 302,
        'sizes': ['XS', 'S', 'M', 'L'], 'colors': ['Oatmeal', 'Sage', 'Dusty Rose'],
        'isNew': false, 'isFeatured': true,
      },
      // ── Accessories ────────────────────────────────────────────────────────
      {
        'name': 'Gold-Tone Chain Necklace', 'brand': 'The Outfit', 'category': 'Accessories',
        'price': 49.99, 'originalPrice': null,
        'imageUrl': 'assets/images/Necklace.jpg',
        'description': 'A minimalist gold-tone chain necklace crafted from tarnish-resistant stainless steel.',
        'rating': 4.4, 'reviewCount': 67,
        'sizes': ['One Size'], 'colors': ['Gold', 'Silver'],
        'isNew': true, 'isFeatured': false,
      },
      {
        'name': 'Leather Bifold Wallet', 'brand': 'The Outfit', 'category': 'Accessories',
        'price': 65.00, 'originalPrice': 85.00,
        'imageUrl': 'assets/images/Wallet.jpg',
        'description': 'A slim bifold wallet handcrafted from full-grain leather. Features 6 card slots.',
        'rating': 4.8, 'reviewCount': 145,
        'sizes': ['One Size'], 'colors': ['Black', 'Tan', 'Cognac'],
        'isNew': false, 'isFeatured': true,
      },
      // ── Footwear ───────────────────────────────────────────────────────────
      {
        'name': 'Chelsea Leather Boots', 'brand': 'The Outfit', 'category': 'Footwear',
        'price': 229.00, 'originalPrice': 299.00,
        'imageUrl': 'assets/images/Boots.jpg',
        'description': 'Handcrafted Chelsea boots in supple full-grain leather.',
        'rating': 4.9, 'reviewCount': 188,
        'sizes': ['7', '8', '9', '10', '11', '12'], 'colors': ['Black', 'Chestnut'],
        'isNew': false, 'isFeatured': true,
      },
      {
        'name': 'Minimalist White Sneakers', 'brand': 'The Outfit', 'category': 'Footwear',
        'price': 120.00, 'originalPrice': null,
        'imageUrl': 'assets/images/Sneakers.jpg',
        'description': 'Clean, minimalist sneakers with a premium leather upper and cushioned insole.',
        'rating': 4.6, 'reviewCount': 234,
        'sizes': ['6', '7', '8', '9', '10', '11'], 'colors': ['White', 'Black'],
        'isNew': true, 'isFeatured': false,
      },
      // ── Outerwear ──────────────────────────────────────────────────────────
      {
        'name': 'Longline Wool Overcoat', 'brand': 'The Outfit', 'category': 'Outerwear',
        'price': 349.00, 'originalPrice': 450.00,
        'imageUrl': 'assets/images/Overcoat.jpg',
        'description': 'A statement longline overcoat in a premium wool-cashmere blend.',
        'rating': 4.9, 'reviewCount': 91,
        'sizes': ['S', 'M', 'L', 'XL'], 'colors': ['Camel', 'Black', 'Grey'],
        'isNew': false, 'isFeatured': true,
      },
      {
        'name': 'Quilted Puffer Jacket', 'brand': 'The Outfit', 'category': 'Outerwear',
        'price': 175.00, 'originalPrice': 220.00,
        'imageUrl': 'assets/images/Jacket.jpg',
        'description': 'A sleek quilted puffer jacket. Lightweight yet incredibly warm.',
        'rating': 4.7, 'reviewCount': 167,
        'sizes': ['XS', 'S', 'M', 'L', 'XL'], 'colors': ['Black', 'Navy', 'Olive'],
        'isNew': true, 'isFeatured': false,
      },
    ];

    // Write all products in a batch
    final batch = db.batch();
    for (final p in products) {
      final ref = col.doc(); // auto-ID
      batch.set(ref, p);
    }
    await batch.commit();
    debugPrint('✅ ${products.length} products seeded to Firestore.');
  }
}
