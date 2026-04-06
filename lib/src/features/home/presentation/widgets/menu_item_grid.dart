import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:web_ordering/src/features/menu/domain/models/category.dart';
import 'package:web_ordering/src/features/menu/domain/models/item.dart';
import 'package:web_ordering/src/features/home/presentation/widgets/menu_item_card.dart';

/// Displays menu items in a 2-column grid.
///
/// When [isSearching] is true, items are filtered across all categories
/// by [searchQuery]. Otherwise, items are filtered by [selectedCategoryIndex].
class MenuItemGrid extends StatelessWidget {
  final List<CategoryModel> categories;
  final List<ItemModel> items;
  final bool isSearching;
  final String searchQuery;
  final int selectedCategoryIndex;
  final int? deptId;

  const MenuItemGrid({
    super.key,
    required this.categories,
    required this.items,
    required this.isSearching,
    required this.searchQuery,
    required this.selectedCategoryIndex,
    this.deptId,
  });

  static const _gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    childAspectRatio: 0.85,
    crossAxisSpacing: 15,
    mainAxisSpacing: 15,
  );

  static const _padding = EdgeInsets.fromLTRB(10, 10, 10, 100);

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const Center(child: Text('No categories found.'));
    }

    final filteredItems = _resolveItems();

    if (filteredItems.isEmpty) {
      return Center(
        child: Text(
          isSearching ? 'No items match your search.' : 'No items in this category.',
        ),
      );
    }

    return GridView.builder(
      padding: _padding,
      gridDelegate: _gridDelegate,
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        return MenuItemCard(
          item: item,
          deptId: deptId,
          onAddPressed: () => context.push('/item/${item.id}', extra: item),
        );
      },
    );
  }

  List<ItemModel> _resolveItems() {
    if (isSearching) {
      if (searchQuery.isEmpty) return items;
      return items.where((i) => i.name.toLowerCase().contains(searchQuery)).toList();
    }

    if (selectedCategoryIndex >= categories.length) return [];
    final selectedCategory = categories[selectedCategoryIndex];
    return items.where((i) => i.categoryId == selectedCategory.id).toList();
  }
}
