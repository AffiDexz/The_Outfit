// lib/screens/wishlist_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../utils/app_constants.dart';
import '../widgets/wishlist_item.dart';

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
        // Back button only appears when pushed as a separate route
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
                style: TextStyle(color: AppColors.accent, fontSize: 12),
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
                return WishlistItem(
                  product: product,
                  onRemove: () => wishlist.remove(product.id),
                  onTap: () => Navigator.pushNamed(
                    ctx,
                    AppRoutes.productDetail,
                    arguments: {
                      'product': product,
                      'heroTag': 'wishlist_${product.id}',
                    },
                  ),
                  onAddToCart: () {
                    cart.addItem(product);
                    wishlist.remove(product.id);
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                color: AppColors.accent),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '${product.name} added to cart!',
                                style: const TextStyle(color: AppColors.white),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: AppColors.surface,
                        duration: const Duration(seconds: 2),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        behavior: SnackBarBehavior.floating,
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                  },
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ── Empty Wishlist State ───────────────────────────────────────────────────────
class _EmptyWishlist extends StatelessWidget {
  const _EmptyWishlist();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with decorative ring
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
              style: TextStyle(color: AppColors.textMuted, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Fixed-width button — no longer expands to full screen width
            SizedBox(
              width: 220,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(
                  context,
                  AppRoutes.productList,
                  arguments: {'category': 'All'},
                ),
                icon: const Icon(Icons.storefront_outlined, size: 18),
                label: const Text(
                  'EXPLORE PRODUCTS',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
