import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:web_ordering/src/features/menu/domain/models/category.dart';
import 'package:web_ordering/src/features/menu/domain/models/item.dart';
import 'package:web_ordering/src/features/menu/presentation/bloc/master_bloc.dart';
import 'package:web_ordering/src/features/home/presentation/widgets/menu_header.dart';
import 'package:web_ordering/src/features/home/presentation/widgets/category_sidebar.dart';
import 'package:web_ordering/src/features/home/presentation/widgets/menu_item_card.dart';
import 'package:web_ordering/src/features/home/presentation/widgets/cart_floating_button.dart';
import 'package:web_ordering/src/features/cart/presentation/widgets/cart_bottom_sheet.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int _selectedCategoryIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const MenuHeader(),
          const Divider(),
          Expanded(
            child: BlocBuilder<MasterBloc, MasterState>(
              builder: (context, state) {
                if (state is MasterLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is MasterError) {
                  return Center(child: Text('Error: ${state.message}'));
                } else if (state is MasterLoaded) {
                  return Stack(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CategorySidebar(
                            categories: state.categories,
                            selectedIndex: _selectedCategoryIndex,
                            onCategorySelected: (index) {
                              setState(() => _selectedCategoryIndex = index);
                            },
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12.0,
                                    horizontal: 16,
                                  ),
                                  child: Text(
                                    state
                                        .categories[_selectedCategoryIndex]
                                        .name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: _buildItemGrid(
                                    state.categories,
                                    state.items,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      CartFloatingButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => const CartBottomSheet(),
                          );
                        },
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemGrid(List<CategoryModel> categories, List<ItemModel> items) {
    if (categories.isEmpty) {
      return const Center(child: Text("No categories found."));
    }

    if (_selectedCategoryIndex >= categories.length) {
      return const SizedBox.shrink();
    }

    final selectedCategory = categories[_selectedCategoryIndex];
    final filteredItems = items
        .where((i) => i.categoryId == selectedCategory.id)
        .toList();

    if (filteredItems.isEmpty) {
      return const Center(child: Text("No items in this category."));
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        return MenuItemCard(
          item: filteredItems[index],
          onAddPressed: () {
            context.push(
              '/item/${filteredItems[index].id}',
              extra: filteredItems[index],
            );
          },
        );
      },
    );
  }
}
