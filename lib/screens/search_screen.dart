// lib/screens/search_screen.dart
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_data.dart';
import '../utils/app_constants.dart';
import '../widgets/product_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl     = TextEditingController();
  final _focusNode = FocusNode();
  String _query   = '';
  String _selectedCategory = 'All';

  static const _recent = [
    'Wool Coat', 'Chelsea Boots', 'Silk Dress', 'Sneakers', 'Wallet'
  ];

  List<Product> get _results {
    var list = _query.isEmpty
        ? ProductData.byCategory(_selectedCategory)
        : ProductData.search(_query);
    if (_selectedCategory != 'All' && _query.isNotEmpty) {
      list = list.where((p) => p.category == _selectedCategory).toList();
    }
    return list;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _ctrl,
          focusNode: _focusNode,
          style: const TextStyle(color: AppColors.white, fontSize: 15),
          cursorColor: AppColors.accent,
          decoration: InputDecoration(
            hintText: 'Search products...',
            hintStyle: const TextStyle(color: AppColors.textMuted),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded,
                        color: AppColors.textMuted, size: 18),
                    onPressed: () {
                      _ctrl.clear();
                      setState(() => _query = '');
                    },
                  )
                : null,
          ),
          onChanged: (v) => setState(() => _query = v),
        ),
      ),
      body: Column(
        children: [
          // ── Category filter ────────────────────────────────────────────────
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              children: ProductData.categories.map((cat) {
                final sel = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.accent : AppColors.surface,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: sel ? AppColors.accent : AppColors.divider,
                      ),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        color: sel ? AppColors.primary : AppColors.white,
                        fontSize: 12,
                        fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // ── Content ────────────────────────────────────────────────────────
          Expanded(
            child: _query.isEmpty
                ? _EmptySearch(
                    recent: _recent,
                    onRecentTap: (q) {
                      _ctrl.text = q;
                      setState(() => _query = q);
                    },
                  )
                : _SearchResults(results: _results, query: _query),
          ),
        ],
      ),
    );
  }
}

class _EmptySearch extends StatelessWidget {
  final List<String> recent;
  final ValueChanged<String> onRecentTap;
  const _EmptySearch({required this.recent, required this.onRecentTap});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recent Searches',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: recent
                .map((q) => GestureDetector(
                      onTap: () => onRecentTap(q),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.history_rounded,
                                color: AppColors.textMuted, size: 14),
                            const SizedBox(width: 6),
                            Text(q,
                                style: const TextStyle(
                                    color: AppColors.white, fontSize: 13)),
                          ],
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 32),
          const Text('Trending Now',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 12),
          ...['Outerwear', 'Footwear', 'Accessories'].map(
            (cat) => GestureDetector(
              onTap: () => onRecentTap(cat),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.trending_up_rounded,
                        color: AppColors.accent, size: 18),
                    const SizedBox(width: 12),
                    Text(cat,
                        style: const TextStyle(
                            color: AppColors.white, fontSize: 14)),
                    const Spacer(),
                    const Icon(Icons.north_east_rounded,
                        color: AppColors.textMuted, size: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  final List<Product> results;
  final String query;
  const _SearchResults({required this.results, required this.query});

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded,
                color: AppColors.divider, size: 64),
            const SizedBox(height: 16),
            Text(
              'No results for "$query"',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try a different search term',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
          child: Row(
            children: [
              Text(
                '${results.length} result${results.length == 1 ? '' : 's'} for "$query"',
                style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 12),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.68,
            ),
            itemCount: results.length,
            itemBuilder: (ctx, i) {
              final p = results[i];
              return ProductCard(
                product: p,
                heroTag: 'search_${p.id}',
                onTap: () => Navigator.pushNamed(
                  ctx,
                  AppRoutes.productDetail,
                  arguments: {
                    'product': p,
                    'heroTag': 'search_${p.id}',
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
