// lib/screens/product_listing_screen.dart
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_data.dart';
import '../utils/app_constants.dart';
import '../widgets/category_card.dart';
import '../widgets/product_card.dart';

class ProductListingScreen extends StatefulWidget {
  const ProductListingScreen({super.key});

  @override
  State<ProductListingScreen> createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  String _selectedCategory = 'All';
  String _sortBy = 'Featured';
  final _sorts = ['Featured', 'Price: Low to High', 'Price: High to Low', 'Rating'];

  List<Product> get _products {
    var list = ProductData.byCategory(_selectedCategory);
    switch (_sortBy) {
      case 'Price: Low to High':
        list = [...list]..sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Price: High to Low':
        list = [...list]..sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Rating':
        list = [...list]..sort((a, b) => b.rating.compareTo(a.rating));
        break;
      default:
        list = [...list]..sort((a, b) => (b.isFeatured ? 1 : 0).compareTo(a.isFeatured ? 1 : 0));
    }
    return list;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args != null && args['category'] != null) {
      _selectedCategory = args['category'];
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = _products;
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: Text(_selectedCategory == 'All' ? 'All Products' : _selectedCategory),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.search),
          ),
          // Sort menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort_rounded),
            color: AppColors.surface,
            onSelected: (v) => setState(() => _sortBy = v),
            itemBuilder: (_) => _sorts
                .map((s) => PopupMenuItem(
                      value: s,
                      child: Text(
                        s,
                        style: TextStyle(
                          color: _sortBy == s ? AppColors.accent : AppColors.white,
                          fontSize: 13,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category filter row
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              itemCount: ProductData.categories.length,
              itemBuilder: (_, i) {
                final cat = ProductData.categories[i];
                return CategoryCard(
                  label: cat,
                  isSelected: _selectedCategory == cat,
                  onTap: () => setState(() => _selectedCategory = cat),
                );
              },
            ),
          ),
          // Result count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${products.length} items',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
                const Spacer(),
                Text(
                  _sortBy,
                  style: const TextStyle(color: AppColors.accent, fontSize: 12),
                ),
              ],
            ),
          ),
          // Grid
          Expanded(
            child: products.isEmpty
                ? const Center(
                    child: Text('No products found',
                        style: TextStyle(color: AppColors.textMuted)))
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.68,
                    ),
                    itemCount: products.length,
                    itemBuilder: (ctx, i) {
                      final p = products[i];
                      return ProductCard(
                        product: p,
                        heroTag: 'list_${p.id}',
                        onTap: () => Navigator.pushNamed(
                          ctx,
                          AppRoutes.productDetail,
                          arguments: {
                            'product': p,
                            'heroTag': 'list_${p.id}',
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
}
