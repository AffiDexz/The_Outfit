// lib/screens/wishlist_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../utils/app_constants.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlist = context.watch<WishlistProvider>();
    final cart     = context.read<CartProvider>();

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: Text('Wishlist (${wishlist.count})'),
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        actions: [
          if (wishlist.items.isNotEmpty)
            TextButton(
              onPressed: () => _addAllToCart(context),
              child: const Text(
                'Add All to Cart',
                style: TextStyle(
                    color: AppColors.accent, fontSize: 12),
              ),
            ),
        ],
      ),
      body: wishlist.items.isEmpty
          ? const _EmptyWishlist()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: wishlist.items.length,
              itemBuilder: (ctx, i) {
                final product = wishlist.items[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      // Product image
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(
                          ctx,
                          AppRoutes.productDetail,
                          arguments: {
                            'product': product,
                            'heroTag': 'wishlist_${product.id}',
                          },
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            product.imageUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 80,
                              height: 80,
                              color: AppColors.surface,
                              child: const Icon(
                                  Icons.image_not_supported,
                                  color: AppColors.textMuted),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.brand.toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.accent,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              product.name,
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text(
                                  '\$${product.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: AppColors.accent,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (product.originalPrice != null) ...[
                                  const SizedBox(width: 6),
                                  Text(
                                    '\$${product.originalPrice!.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 11,
                                      decoration:
                                          TextDecoration.lineThrough,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Add to cart button
                            GestureDetector(
                              onTap: () {
                                cart.addItem(product);
                                wishlist.remove(product.id);
                                ScaffoldMessenger.of(ctx)
                                    .showSnackBar(
                                  SnackBar(
                                    content: Row(children: [
                                      const Icon(
                                          Icons.check_circle_rounded,
                                          color: AppColors.accent),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          '${product.name} added to cart!',
                                          style: const TextStyle(
                                              color: AppColors.white),
                                          overflow:
                                              TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ]),
                                    backgroundColor: AppColors.surface,
                                    duration:
                                        const Duration(seconds: 2),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    behavior: SnackBarBehavior.floating,
                                    margin: const EdgeInsets.all(16),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.accent,
                                  borderRadius:
                                      BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                        Icons.shopping_bag_outlined,
                                        color: AppColors.primary,
                                        size: 13),
                                    SizedBox(width: 5),
                                    Text(
                                      'ADD TO CART',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Remove heart button
                      IconButton(
                        onPressed: () =>
                            wishlist.remove(product.id),
                        icon: const Icon(
                          Icons.favorite_rounded,
                          color: AppColors.accent,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  void _addAllToCart(BuildContext context) {
    final wishlist = context.read<WishlistProvider>();
    final cart     = context.read<CartProvider>();
    final items    = List.from(wishlist.items);
    for (final p in items) {
      cart.addItem(p);
      wishlist.remove(p.id);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${items.length} item(s) moved to cart!',
          style: const TextStyle(color: AppColors.white),
        ),
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ── Empty Wishlist ─────────────────────────────────────────────────────────────
class _EmptyWishlist extends StatelessWidget {
  const _EmptyWishlist();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
                border: Border.all(color: AppColors.divider),
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                color: AppColors.divider,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Your wishlist is empty',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Save items you love for later',
              style: TextStyle(
                  color: AppColors.textMuted, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // ── Fixed-width centred button ──────────────────────────
            SizedBox(
              width: 220,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(
                  context,
                  AppRoutes.productList,
                  arguments: {'category': 'All'},
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                  padding: EdgeInsets.zero,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.storefront_outlined, size: 18,
                        color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      'EXPLORE PRODUCTS',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}