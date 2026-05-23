// lib/screens/product_listing_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../models/product_model.dart';
import '../utils/app_constants.dart';
import '../widgets/product_card.dart';

class ProductListingScreen extends StatefulWidget {
  const ProductListingScreen({super.key});

  @override
  State<ProductListingScreen> createState() =>
      _ProductListingScreenState();
}

class _ProductListingScreenState
    extends State<ProductListingScreen> {
  // Local category state — does NOT affect HomeScreen
  String _selectedCategory = 'All';
  String _sortBy = 'Featured';
  bool   _initialized = false;

  final _sortOptions = [
    'Featured',
    'Price: Low to High',
    'Price: High to Low',
    'Top Rated',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      // Read initial category from route arguments
      final args =
          ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is Map) {
        final cat = args['category'] as String?;
        if (cat != null && cat.isNotEmpty) {
          setState(() => _selectedCategory = cat);
        }
      }
    }
  }

  // Filter and sort products locally
  List<Product> _getProducts(List<Product> all) {
    // Filter by category
    var list = _selectedCategory == 'All'
        ? all
        : all.where((p) => p.category == _selectedCategory).toList();

    // Apply sort
    switch (_sortBy) {
      case 'Price: Low to High':
        list = [...list]..sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Price: High to Low':
        list = [...list]..sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Top Rated':
        list = [...list]..sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final provider  = context.watch<ProductProvider>();
    final allProducts = provider.products;
    final products  = _getProducts(allProducts);
    const categories = ProductProvider.categories;

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: Text(_selectedCategory == 'All'
            ? 'All Products'
            : _selectedCategory),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.search),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Category pills ─────────────────────────────────────
          SizedBox(
            height: 52,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              itemCount: categories.length,
              itemBuilder: (_, i) {
                final cat      = categories[i];
                final selected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.accent
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: selected
                            ? AppColors.accent
                            : AppColors.divider,
                      ),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        color: selected
                            ? AppColors.primary
                            : AppColors.white,
                        fontSize: 12,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Meta row ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${products.length} item(s)',
                  style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12),
                ),
                GestureDetector(
                  onTap: () => _showSortSheet(context),
                  child: Row(
                    children: [
                      Text(
                        _sortBy,
                        style: const TextStyle(
                            color: AppColors.accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w500),
                      ),
                      const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.accent,
                          size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Loading ────────────────────────────────────────────
          if (provider.loading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(
                    color: AppColors.accent,
                    strokeWidth: 1.5),
              ),
            )

          // ── Empty ──────────────────────────────────────────────
          else if (products.isEmpty)
            const Expanded(
              child: Center(
                child: Text(
                  'No products found',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
            )

          // ── Grid ───────────────────────────────────────────────
          else
            Expanded(
              child: GridView.builder(
                padding:
                    const EdgeInsets.fromLTRB(16, 8, 16, 100),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.68,
                ),
                itemCount: products.length,
                itemBuilder: (ctx, i) {
                  final product = products[i];
                  return ProductCard(
                    product: product,
                    heroTag: 'list_\${product.id}',
                    onTap: () => Navigator.pushNamed(
                      ctx,
                      AppRoutes.productDetail,
                      arguments: {
                        'product': product,
                        'heroTag': 'list_\${product.id}',
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _showSortSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Sort By',
                style: TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ..._sortOptions.map((opt) => ListTile(
                  title: Text(opt,
                      style: TextStyle(
                          color: _sortBy == opt
                              ? AppColors.accent
                              : AppColors.white,
                          fontWeight: _sortBy == opt
                              ? FontWeight.w600
                              : FontWeight.w400)),
                  trailing: _sortBy == opt
                      ? const Icon(Icons.check_rounded,
                          color: AppColors.accent)
                      : null,
                  onTap: () {
                    setState(() => _sortBy = opt);
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }
}