// lib/screens/search_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/product_provider.dart';
import '../utils/app_constants.dart';
import '../widgets/product_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchCtrl     = TextEditingController();
  String _selectedCategory = 'All';
  bool   _isSearching   = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSearch(String query) async {
    final provider = context.read<ProductProvider>();
    setState(() => _isSearching = true);
    await provider.search(query);
    setState(() => _isSearching = false);
  }

  void _clear() {
    _searchCtrl.clear();
    context.read<ProductProvider>().clearSearch();
    setState(() {});
  }

  // Filter search results by category
  List<Product> _filterByCategory(List<Product> results) {
    if (_selectedCategory == 'All') return results;
    return results
        .where((p) => p.category == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider     = context.watch<ProductProvider>();
    final allProducts  = provider.products;
    final searchResults = _filterByCategory(provider.searchResults);
    final hasQuery     = _searchCtrl.text.trim().isNotEmpty;

    // When no query — show all products filtered by category
    final displayProducts = hasQuery
        ? searchResults
        : _filterByCategory(allProducts);

    const categories = ProductProvider.categories;

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchCtrl,
          autofocus: true,
          style: const TextStyle(color: AppColors.white, fontSize: 15),
          decoration: InputDecoration(
            hintText: 'Search products...',
            hintStyle:
                const TextStyle(color: AppColors.textMuted, fontSize: 15),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            suffixIcon: _searchCtrl.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: AppColors.textMuted, size: 18),
                    onPressed: _clear,
                  )
                : null,
          ),
          onChanged: (v) {
            setState(() {});
            if (v.trim().isNotEmpty) {
              _onSearch(v.trim());
            } else {
              context.read<ProductProvider>().clearSearch();
            }
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.divider),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Category filter pills ──────────────────────────────────────────
          SizedBox(
            height: 52,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: categories.length,
              itemBuilder: (_, i) {
                final cat = categories[i];
                final selected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
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

          // ── Results count ──────────────────────────────────────────────────
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              hasQuery
                  ? '${displayProducts.length} result(s) for "${_searchCtrl.text}"'
                  : '${displayProducts.length} product(s)',
              style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 12),
            ),
          ),

          // ── Loading ────────────────────────────────────────────────────────
          if (_isSearching)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.accent, strokeWidth: 1.5),
              ),
            )

          // ── No results ─────────────────────────────────────────────────────
          else if (displayProducts.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.search_off_rounded,
                        color: AppColors.divider, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      hasQuery
                          ? 'No results for "${_searchCtrl.text}"'
                          : 'No products found',
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 14),
                    ),
                  ],
                ),
              ),
            )

          // ── Product grid ───────────────────────────────────────────────────
          else
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.68,
                ),
                itemCount: displayProducts.length,
                itemBuilder: (ctx, i) {
                  final product = displayProducts[i];
                  return ProductCard(
                    product: product,
                    heroTag: 'search_${product.id}',
                    onTap: () => Navigator.pushNamed(
                      ctx,
                      AppRoutes.productDetail,
                      arguments: {
                        'product': product,
                        'heroTag': 'search_${product.id}',
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