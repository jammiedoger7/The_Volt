import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../providers/wardrobe_provider.dart';
import '../../models/wardrobe_item.dart';
import '../../widgets/wardrobe/wardrobe_card.dart';
import 'add_item_screen.dart';

class WardrobeScreen extends ConsumerStatefulWidget {
  const WardrobeScreen({super.key});

  @override
  ConsumerState<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends ConsumerState<WardrobeScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final _categories = ['All', 'Tops', 'Bottoms', 'Shoes', 'Outerwear', 'Accessories'];

  ClothingCategory? get _filterCategory {
    if (_selectedCategory == 'All') return null;
    return ClothingCategory.values.firstWhere(
      (c) => c.name == _selectedCategory.toLowerCase(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wardrobe = ref.watch(wardrobeProvider);

    final filteredItems = wardrobe.valueOrNull?.where((item) {
      final matchesCategory = _filterCategory == null || item.category == _filterCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.color.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList() ?? [];

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Wardrobe',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AddItemScreen()),
                    );
                  },
                  icon: const Icon(Icons.add_circle, color: AppColors.electricBlue, size: 32),
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search items...',
                prefixIcon: const Icon(Icons.search, color: AppColors.mediumGray),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.mediumGray),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Category filters
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final isSelected = _categories[index] == _selectedCategory;
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(_categories[index]),
                    onSelected: (_) => setState(() => _selectedCategory = _categories[index]),
                    selectedColor: AppColors.electricBlue,
                    backgroundColor: AppColors.darkGray,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.matteBlack : AppColors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Items count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${filteredItems.length} item${filteredItems.length != 1 ? 's' : ''}',
                style: const TextStyle(color: AppColors.mediumGray, fontSize: 13),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Wardrobe grid
          Expanded(
            child: wardrobe.when(
              data: (_) => filteredItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.checkroom, size: 64, color: AppColors.mediumGray),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'No items match "$_searchQuery"'
                                : 'Your wardrobe is empty',
                            style: const TextStyle(color: AppColors.mediumGray, fontSize: 18),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Tap + to add your first item',
                            style: TextStyle(color: AppColors.mediumGray, fontSize: 14),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        return WardrobeCard(
                          name: item.name,
                          category: item.category.name,
                          imageUrl: item.imageUrl,
                          color: item.color,
                          onTap: () {
                            _showItemDetails(item);
                          },
                        );
                      },
                    ),
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.electricBlue),
              ),
              error: (e, _) => Center(
                child: Text('Error: $e', style: const TextStyle(color: AppColors.error)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showItemDetails(WardrobeItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkGray,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.mediumGray.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(item.name, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            _DetailRow('Category', item.category.name),
            _DetailRow('Color', item.color),
            if (item.material != null) _DetailRow('Material', item.material!),
            if (item.brand != null) _DetailRow('Brand', item.brand!),
            if (item.style != null) _DetailRow('Style', item.style!.name),
            _DetailRow('Warmth', '${item.warmthRating}/10'),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await ref.read(wardrobeProvider.notifier).deleteItem(item.id);
                      if (context.mounted) Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.delete_outline, color: AppColors.error),
                    label: const Text('Delete', style: TextStyle(color: AppColors.error)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.mediumGray)),
          Text(value, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
