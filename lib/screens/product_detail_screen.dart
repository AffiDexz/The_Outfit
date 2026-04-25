// lib/screens/product_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../utils/app_constants.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with TickerProviderStateMixin {
  late Product _product;
  late String _heroTag;
  String? _selectedSize;
  String? _selectedColor;
  bool _added = false;

  // ── Animation controllers ──────────────────────────────────────────────────
  // Primary scale controller: multi-phase spring sequence
  late AnimationController _scaleCtrl;
  late Animation<double> _scaleAnim;

  // Secondary glow/color controller: fades in success glow then out
  late AnimationController _glowCtrl;
  late Animation<double> _glowAnim;

  // Particle burst controller: expands and fades small dots
  late AnimationController _particleCtrl;
  late Animation<double> _particleAnim;

  @override
  void initState() {
    super.initState();

    // ── Scale: compress → overshoot → settle ────────────────────────────────
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _scaleAnim = TweenSequence<double>([
      // Quick compress down
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.92)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 15,
      ),
      // Overshoot up (elastic feel)
      TweenSequenceItem(
        tween: Tween(begin: 0.92, end: 1.12)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      // Settle back with slight wobble
      TweenSequenceItem(
        tween: Tween(begin: 1.12, end: 0.97)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.97, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
    ]).animate(_scaleCtrl);

    // ── Glow: fade in then out ───────────────────────────────────────────────
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _glowAnim = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 0.0, end: 1.0)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 30),
      TweenSequenceItem(
          tween: ConstantTween(1.0),
          weight: 30),
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 0.0)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 40),
    ]).animate(_glowCtrl);

    // ── Particle: expand and fade ────────────────────────────────────────────
    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _particleAnim = CurvedAnimation(
      parent: _particleCtrl,
      curve: Curves.easeOut,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    _product = args['product'] as Product;
    _heroTag = args['heroTag'] as String;
    _selectedSize  ??= _product.sizes.first;
    _selectedColor ??= _product.colors.first;
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    _glowCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  // ── Add to cart with multi-phase animation ─────────────────────────────────
  void _addToCart() {
    if (_added) return; // prevent double-tap during animation

    final cart = context.read<CartProvider>();
    cart.addItem(_product, size: _selectedSize, color: _selectedColor);

    // Haptic feedback
    HapticFeedback.mediumImpact();

    // Fire all three animations simultaneously
    _scaleCtrl.forward(from: 0);
    _glowCtrl.forward(from: 0);
    _particleCtrl.forward(from: 0);

    setState(() => _added = true);

    // Snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.accent),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${_product.name} added to cart!',
                style: const TextStyle(color: AppColors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.surface,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );

    // Reset _added state after 2 s so button is interactive again
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _added = false);
        _scaleCtrl.reset();
        _glowCtrl.reset();
        _particleCtrl.reset();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final wishlist     = context.watch<WishlistProvider>();
    final isWishlisted = wishlist.isWishlisted(_product.id);

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: CustomScrollView(
        slivers: [
          // ── Hero Image AppBar ──────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 420,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(179),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppColors.white, size: 18),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () => wishlist.toggle(_product),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(179),
                    shape: BoxShape.circle,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      isWishlisted
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      key: ValueKey(isWishlisted),
                      color: isWishlisted
                          ? AppColors.accent
                          : AppColors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: _heroTag,
                child: Image.network(
                  _product.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (ctx, child, prog) => prog == null
                      ? child
                      : Container(
                          color: AppColors.surface,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.accent,
                              strokeWidth: 1.5,
                            ),
                          ),
                        ),
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.surface,
                    child: const Icon(Icons.image_not_supported,
                        color: AppColors.textMuted, size: 60),
                  ),
                ),
              ),
            ),
          ),

          // ── Product Info ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand + badges
                    Row(
                      children: [
                        Text(
                          _product.brand.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                          ),
                        ),
                        const Spacer(),
                        if (_product.isNew) _badge('NEW', AppColors.accent),
                        if (_product.discountPercent > 0) ...[
                          const SizedBox(width: 6),
                          _badge('-${_product.discountPercent.toInt()}%',
                              AppColors.error),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _product.name,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Price + rating
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '\$${_product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (_product.originalPrice != null) ...[
                          const SizedBox(width: 10),
                          Text(
                            '\$${_product.originalPrice!.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 15,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                        const Spacer(),
                        const Icon(Icons.star_rounded,
                            color: AppColors.accent, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${_product.rating}',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${_product.reviewCount})',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: AppColors.divider),
                    const SizedBox(height: 20),

                    // ── Size selector ──────────────────────────────────────────
                    const Text('Select Size',
                        style: TextStyle(
                            color: AppColors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: _product.sizes.map((size) {
                        final selected = _selectedSize == size;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedSize = size),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.accent
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: selected
                                    ? AppColors.accent
                                    : AppColors.divider,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                size,
                                style: TextStyle(
                                  color: selected
                                      ? AppColors.primary
                                      : AppColors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // ── Color selector ─────────────────────────────────────────
                    const Text('Select Color',
                        style: TextStyle(
                            color: AppColors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: _product.colors.map((color) {
                        final selected = _selectedColor == color;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedColor = color),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.accent.withAlpha(38)
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: selected
                                    ? AppColors.accent
                                    : AppColors.divider,
                                width: selected ? 1.5 : 1,
                              ),
                            ),
                            child: Text(
                              color,
                              style: TextStyle(
                                color: selected
                                    ? AppColors.accent
                                    : AppColors.white,
                                fontSize: 12,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: AppColors.divider),
                    const SizedBox(height: 20),

                    // ── Description ────────────────────────────────────────────
                    const Text('Description',
                        style: TextStyle(
                            color: AppColors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Text(
                      _product.description,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                        height: 1.7,
                      ),
                    ),
                    const SizedBox(height: 36),

                    // ── Add to Cart CTA ────────────────────────────────────────
                    Row(
                      children: [
                        // Wishlist toggle button
                        GestureDetector(
                          onTap: () => wishlist.toggle(_product),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isWishlisted
                                    ? AppColors.accent
                                    : AppColors.divider,
                                width: isWishlisted ? 1.5 : 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              color: isWishlisted
                                  ? AppColors.accent.withAlpha(26)
                                  : Colors.transparent,
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                isWishlisted
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                key: ValueKey(isWishlisted),
                                color: isWishlisted
                                    ? AppColors.accent
                                    : AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // ── Animated Add to Cart button ────────────────────────
                        Expanded(
                          child: _AnimatedCartButton(
                            added: _added,
                            scaleAnim: _scaleAnim,
                            glowAnim: _glowAnim,
                            particleAnim: _particleAnim,
                            onTap: _addToCart,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
}

// ── Animated Cart Button widget ────────────────────────────────────────────────
// Encapsulates the multi-layer animation so the parent stays clean.
class _AnimatedCartButton extends StatelessWidget {
  final bool added;
  final Animation<double> scaleAnim;
  final Animation<double> glowAnim;
  final Animation<double> particleAnim;
  final VoidCallback onTap;

  const _AnimatedCartButton({
    required this.added,
    required this.scaleAnim,
    required this.glowAnim,
    required this.particleAnim,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([scaleAnim, glowAnim, particleAnim]),
      builder: (ctx, _) {
        return Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // ── Glow halo behind the button ──────────────────────────────────
            if (glowAnim.value > 0)
              Positioned.fill(
                child: Opacity(
                  opacity: glowAnim.value * 0.6,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: added
                              ? AppColors.success.withAlpha(128)
                              : AppColors.accent.withAlpha(128),
                          blurRadius: 20 * glowAnim.value,
                          spreadRadius: 2 * glowAnim.value,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // ── Particle burst (4 small dots radiating outward) ───────────────
            if (particleAnim.value > 0 && particleAnim.value < 1)
              ..._buildParticles(particleAnim.value),

            // ── The actual button with scale ──────────────────────────────────
            Transform.scale(
              scale: scaleAnim.value,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: added ? AppColors.success : AppColors.accent,
                  boxShadow: [
                    BoxShadow(
                      color: (added ? AppColors.success : AppColors.accent)
                          .withAlpha(89),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: GestureDetector(
                  onTap: onTap,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder: (child, anim) => ScaleTransition(
                          scale: anim,
                          child: FadeTransition(opacity: anim, child: child),
                        ),
                        child: added
                            ? const Row(
                                key: ValueKey('added'),
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle_rounded,
                                      color: Colors.white, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    '✓  ADDED TO CART',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              )
                            : const Row(
                                key: ValueKey('add'),
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.shopping_bag_outlined,
                                      color: AppColors.primary, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'ADD TO CART',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Build 4 radiating particle dots
  List<Widget> _buildParticles(double progress) {
    const offsets = [
      Offset(0, -1),  // top
      Offset(1, 0),   // right
      Offset(0, 1),   // bottom
      Offset(-1, 0),  // left
    ];
    final opacity = (1.0 - progress).clamp(0.0, 1.0);
    final distance = 30.0 * progress;

    return offsets.map((dir) {
      return Positioned(
        top: 26 + dir.dy * distance - 4,
        left: null,
        child: Transform.translate(
          offset: Offset(dir.dx * distance, 0),
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: added
                    ? AppColors.success.withAlpha(204)
                    : AppColors.accent.withAlpha(204),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
}
