// lib/services/product_data.dart
import '../models/product_model.dart';

class ProductData {
  static const List<String> categories = [
    'All',
    'Men',
    'Women',
    'Accessories',
    'Footwear',
    'Outerwear',
  ];

  static const List<Product> products = [
    // ── Men ──────────────────────────────────────────────────────────────────
    Product(
      id: 'p001',
      name: 'Classic Slim Suit',
      brand: 'The Outfit',
      category: 'Men',
      price: 189.99,
      originalPrice: 249.99,
      imageUrl: 'assets/images/suit.jpg',
      description:
          'A meticulously crafted slim-fit suit in premium Italian wool. Perfect for formal occasions and business meetings. Features a two-button closure, notch lapels, and a fully lined interior for a polished silhouette.',
      rating: 4.8,
      reviewCount: 124,
      sizes: ['S', 'M', 'L', 'XL', 'XXL'],
      colors: ['Charcoal', 'Navy', 'Black'],
      isFeatured: true,
    ),
    Product(
      id: 'p002',
      name: 'Urban Cargo Trousers',
      brand: 'The Outfit',
      category: 'Men',
      price: 79.99,
      imageUrl: 'assets/images/cargo.jpg',
      description:
          'Versatile cargo trousers with a modern silhouette. Crafted from durable cotton-blend fabric with multiple utility pockets. Perfect for urban exploration.',
      rating: 4.5,
      reviewCount: 89,
      sizes: ['S', 'M', 'L', 'XL'],
      colors: ['Olive', 'Black', 'Khaki'],
      isNew: true,
    ),
    Product(
      id: 'p003',
      name: 'Merino Wool Turtleneck',
      brand: 'The Outfit',
      category: 'Men',
      price: 110.00,
      originalPrice: 140.00,
      imageUrl: 'assets/images/turtleneck.jpg',
      description:
          'Luxuriously soft merino wool turtleneck. Temperature regulating, odor-resistant, and incredibly comfortable. A wardrobe essential for cooler months.',
      rating: 4.9,
      reviewCount: 210,
      sizes: ['XS', 'S', 'M', 'L', 'XL'],
      colors: ['Cream', 'Camel', 'Charcoal'],
      isFeatured: true,
    ),
    Product(
      id: 'p004',
      name: 'Long Sleeve Shirt with Double Pockets',
      brand: 'The Outfit',
      category: 'Men',
      price: 1100.00,
      originalPrice: 2000.00,
      imageUrl: 'assets/images/Shirts.jpg',
      description:
          'Wash & Care - Hand wash with cold water, wash inside out, wash light colors separately & iron with care.',
      rating: 4.9,
      reviewCount: 210,
      sizes: ['XS', 'S', 'M', 'L', 'XL'],
      colors: ['Cream', 'Camel', 'Charcoal'],
      isFeatured: true,
    ),

    // ── Women ─────────────────────────────────────────────────────────────────
    Product(
      id: 'p005',
      name: 'Silk Wrap Dress',
      brand: 'The Outfit',
      category: 'Women',
      price: 159.99,
      originalPrice: 210.00,
      imageUrl: 'assets/images/Silk.jpg',
      description:
          'An elegant silk wrap dress that effortlessly transitions from day to evening. The fluid silhouette drapes beautifully on all body types with a flattering V-neckline.',
      rating: 4.7,
      reviewCount: 156,
      sizes: ['XS', 'S', 'M', 'L'],
      colors: ['Ivory', 'Blush', 'Midnight'],
      isFeatured: true,
    ),
    Product(
      id: 'p006',
      name: 'One Shoulder Puff Sleeve Dress',
      brand: 'The Outfit',
      category: 'Women',
      price: 89.99,
      imageUrl: 'assets/images/Puff.jpg',
      description:
          'An elegant silk wrap dress that effortlessly transitions from day to evening. The fluid silhouette drapes beautifully on all body types with a flattering V-neckline.',
      rating: 4.6,
      reviewCount: 98,
      sizes: ['XS', 'S', 'M', 'L', 'XL'],
      colors: ['Black', 'Camel', 'White'],
      isNew: true,
    ),
    Product(
      id: 'p007',
      name: 'Cashmere Knit Cardigan',
      brand: 'The Outfit',
      category: 'Women',
      price: 195.00,
      originalPrice: 250.00,
      imageUrl: 'assets/images/Cardigan.jpg',
      description:
          'An exceptionally soft cashmere cardigan with a relaxed silhouette. Features ribbed cuffs and hem, button closure, and deep side pockets.',
      rating: 4.9,
      reviewCount: 302,
      sizes: ['XS', 'S', 'M', 'L'],
      colors: ['Oatmeal', 'Sage', 'Dusty Rose'],
      isFeatured: true,
    ),
    Product(
      id: 'p008',
      name: 'Linen Look Bow Pocket Waistcoat',
      brand: 'The Outfit',
      category: 'Women',
      price: 195.00,
      originalPrice: 250.00,
      imageUrl: 'assets/images/Linen.jpg',
      description:
          'Elevate your wardrobe with this chic Linen Look Bow Pocket Waistcoat, designed for a perfect blend of sophistication and modern style. Crafted from a lightweight, breathable fabric with a linen-inspired texture, this waistcoat offers both comfort and elegance for all-day wear.',
      rating: 4.9,
      reviewCount: 302,
      sizes: ['XS', 'S', 'M', 'L'],
      colors: ['Oatmeal', 'Sage', 'Dusty Rose'],
      isFeatured: true,
    ),

    // ── Accessories ───────────────────────────────────────────────────────────
    Product(
      id: 'p009',
      name: 'Gold-Tone Chain Necklace',
      brand: 'The Outfit',
      category: 'Accessories',
      price: 49.99,
      imageUrl: 'assets/images/Necklace.jpg',
      description:
          'A minimalist gold-tone chain necklace crafted from tarnish-resistant stainless steel. Timeless and versatile for any occasion.',
      rating: 4.4,
      reviewCount: 67,
      sizes: ['One Size'],
      colors: ['Gold', 'Silver'],
      isNew: true,
    ),
    Product(
      id: 'p010',
      name: 'Pink girly stuff\u{1F380}\u{1F338}',
      brand: 'The Outfit',
      category: 'Accessories',
      price: 49.99,
      imageUrl: 'assets/images/stuff.jpg',
      description:
          'Pink, pinky stuff, girly stuff, pink flower claw clips, pink scalp massager, hair care, detangler hairbrush, pink butterfly bow claw clip, pink skincare headband, gua sha, pink face roller, jade roller, face shaping, pink valentino perfume, valentino born in roma, that girl aesthetic, pink girly, pink aesthetic',
      rating: 4.4,
      reviewCount: 67,
      sizes: ['One Size'],
      colors: ['Gold', 'Silver'],
      isNew: true,
    ),
    Product(
      id: 'p011',
      name: 'Leather Bifold Wallet',
      brand: 'The Outfit',
      category: 'Accessories',
      price: 65.00,
      originalPrice: 85.00,
      imageUrl: 'assets/images/Wallet.jpg',
      description:
          'A slim bifold wallet handcrafted from full-grain leather. Features 6 card slots, a bill compartment, and an ID window. Ages beautifully with use.',
      rating: 4.8,
      reviewCount: 145,
      sizes: ['One Size'],
      colors: ['Black', 'Tan', 'Cognac'],
      isFeatured: true,
    ),
    Product(
      id: 'p012',
      name: 'Mens Elastic Braided Stretch Belt - Beige / 110cm',
      brand: 'The Outfit',
      category: 'Accessories',
      price: 65.00,
      originalPrice: 85.00,
      imageUrl: 'assets/images/Belt.jpg',
      description:
          'Stay Comfortable and Stylish with Our Mens Elastic Braided Stretch Belt. Made from high-quality, woven elastic fabric, this belt is designed for men who prioritize both comfort and fashion. The braided design adds a timeless touch to your wardrobe.',
      rating: 4.8,
      reviewCount: 145,
      sizes: ['One Size'],
      colors: ['Black', 'Tan', 'Cognac'],
      isFeatured: true,
    ),

    // ── Footwear ──────────────────────────────────────────────────────────────
    Product(
      id: 'p013',
      name: 'Chelsea Leather Boots',
      brand: 'The Outfit',
      category: 'Footwear',
      price: 229.00,
      originalPrice: 299.00,
      imageUrl: 'assets/images/Boots.jpg',
      description:
          'Handcrafted Chelsea boots in supple full-grain leather. Elastic side panels for easy on/off, a rubber sole for durability, and a sleek silhouette.',
      rating: 4.9,
      reviewCount: 188,
      sizes: ['7', '8', '9', '10', '11', '12'],
      colors: ['Black', 'Chestnut'],
      isFeatured: true,
    ),
    Product(
      id: 'p014',
      name: 'Minimalist White Sneakers',
      brand: 'The Outfit',
      category: 'Footwear',
      price: 120.00,
      imageUrl: 'assets/images/Sneakers.jpg',
      description:
          'Clean, minimalist sneakers with a premium leather upper and cushioned insole. The perfect everyday shoe that pairs with everything.',
      rating: 4.6,
      reviewCount: 234,
      sizes: ['6', '7', '8', '9', '10', '11'],
      colors: ['White', 'Black'],
      isNew: true,
    ),
    Product(
      id: 'p015',
      name: 'Modern comfortable Style Sneakers',
      brand: 'The Outfit',
      category: 'Footwear',
      price: 120.00,
      imageUrl: 'assets/images/Sneakers2.jpg',
      description:
          'These modern, comfortable style sneakers are designed to offer both cutting-edge fashion and superior comfort. With a sleek, contemporary look, they incorporate innovative materials and design features that enhance both aesthetics and wearability.',
      rating: 4.6,
      reviewCount: 234,
      sizes: ['6', '7', '8', '9', '10', '11'],
      colors: ['White', 'Black'],
      isNew: true,
    ),
    Product(
      id: 'p016',
      name: 'Mens Colorful Pattern Design Loafers',
      brand: 'The Outfit',
      category: 'Footwear',
      price: 120.00,
      imageUrl: 'assets/images/Shoes.jpg',
      description:
          'Immerse yourself in the world of luxury with our Handcrafted Mens Brown Derby Leather Shoes. Made from premium leather, these shoes are a testament to superior craftsmanship and attention to detail. Perfect for formal occasions, they add a touch of elegance to any outfit.',
      rating: 4.6,
      reviewCount: 234,
      sizes: ['6', '7', '8', '9', '10', '11'],
      colors: ['White', 'Black', 'Brown'],
      isNew: true,
    ),

    // ── Outerwear ─────────────────────────────────────────────────────────────
    Product(
      id: 'p017',
      name: 'Longline Wool Overcoat',
      brand: 'The Outfit',
      category: 'Outerwear',
      price: 349.00,
      originalPrice: 450.00,
      imageUrl: 'assets/images/Overcoat.jpg',
      description:
          'A statement longline overcoat in a premium wool-cashmere blend. Double-breasted silhouette with structured shoulders and a refined lapel.',
      rating: 4.9,
      reviewCount: 91,
      sizes: ['S', 'M', 'L', 'XL'],
      colors: ['Camel', 'Black', 'Grey'],
      isFeatured: true,
    ),
    Product(
      id: 'p018',
      name: 'Quilted Puffer Jacket',
      brand: 'The Outfit',
      category: 'Outerwear',
      price: 175.00,
      originalPrice: 220.00,
      imageUrl: 'assets/images/Jacket.jpg',
      description:
          'A sleek quilted puffer jacket with down-alternative fill. Lightweight yet incredibly warm. Features a packable design and hidden zip pockets.',
      rating: 4.7,
      reviewCount: 167,
      sizes: ['XS', 'S', 'M', 'L', 'XL'],
      colors: ['Black', 'Navy', 'Olive'],
      isNew: true,
    ),
    Product(
      id: 'p019',
      name: 'Mens Solid Color Basic Zipper Jacket',
      brand: 'The Outfit',
      category: 'Outerwear',
      price: 175.00,
      originalPrice: 220.00,
      imageUrl: 'assets/images/Zipper.jpg',
      description:
          'Mens Solid Color Basic Zipper Jacket, Fall Clothes, Khaki Casual - Modern Casual Long Sleeve Woven Fabric, Slight Stretch, Spring/Fall, Fall/Winter Men Clothing.',
      rating: 4.7,
      reviewCount: 167,
      sizes: ['XS', 'S', 'M', 'L', 'XL'],
      colors: ['Black', 'Navy', 'Olive'],
      isNew: true,
    ),
    Product(
      id: 'p020',
      name: 'Reversible Pile Jacket for Children',
      brand: 'The Outfit',
      category: 'Outerwear',
      price: 175.00,
      originalPrice: 220.00,
      imageUrl: 'assets/images/Children.jpg',
      description:
          'Jackson reversible childrens thermo jacket. Explore our versatile spring jacket - comfortable, practical and ideal for outdoor play. Made from 100% recycled polyester with a soft Sherpa padding and quilted shell.',
      rating: 4.7,
      reviewCount: 167,
      sizes: ['XS', 'S', 'M', 'L', 'XL'],
      colors: ['Black', 'Navy', 'Olive'],
      isNew: true,
    ),
  ];

  /// Filter products by category (returns all if 'All')
  static List<Product> byCategory(String category) {
    if (category == 'All') return products;
    return products.where((p) => p.category == category).toList();
  }

  /// Filter products by search query
  static List<Product> search(String query) {
    final q = query.toLowerCase();
    return products.where((p) {
      return p.name.toLowerCase().contains(q) ||
          p.brand.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q);
    }).toList();
  }

  static List<Product> get featured =>
      products.where((p) => p.isFeatured).toList();

  static List<Product> get newArrivals =>
      products.where((p) => p.isNew).toList();
}