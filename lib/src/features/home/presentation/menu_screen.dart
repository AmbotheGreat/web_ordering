import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:web_ordering/src/features/menu/presentation/bloc/master_bloc.dart';
import 'package:web_ordering/src/features/home/presentation/widgets/menu_header.dart';
import 'package:web_ordering/src/features/home/presentation/widgets/menu_search_bar.dart';
import 'package:web_ordering/src/features/home/presentation/widgets/category_sidebar.dart';
import 'package:web_ordering/src/features/home/presentation/widgets/menu_item_grid.dart';
import 'package:web_ordering/src/features/home/presentation/widgets/cart_floating_button.dart';
import 'package:web_ordering/src/features/cart/presentation/widgets/cart_bottom_sheet.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int _selectedCategoryIndex = 0;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchQuery = '';
      }
    });
  }

  void _closeSearch() {
    FocusScope.of(context).unfocus();
    setState(() {
      _isSearching = false;
      _searchController.clear();
      _searchQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _isSearching ? _closeSearch : null,
        child: Column(
          children: [
            MenuHeader(onSearchPressed: _toggleSearch),
            if (_isSearching)
              MenuSearchBar(
                controller: _searchController,
                query: _searchQuery,
                onChanged: (value) =>
                    setState(() => _searchQuery = value.trim().toLowerCase()),
                onClear: () => setState(() {
                  _searchController.clear();
                  _searchQuery = '';
                }),
              ),
            const Divider(height: 1),
            Expanded(
              child: BlocBuilder<MasterBloc, MasterState>(
                builder: (context, state) {
                  if (state is MasterLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is MasterError) {
                    return Center(child: Text('Error: ${state.message}'));
                  }
                  if (state is MasterLoaded) {
                    return Stack(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!_isSearching)
                              CategorySidebar(
                                categories: state.categories,
                                selectedIndex: _selectedCategoryIndex,
                                onCategorySelected: (index) => setState(
                                  () => _selectedCategoryIndex = index,
                                ),
                              ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 16,
                                    ),
                                    child: Text(
                                      _isSearching
                                          ? 'All Items'
                                          : state
                                                .categories[_selectedCategoryIndex]
                                                .name,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: MenuItemGrid(
                                      categories: state.categories,
                                      items: state.items,
                                      isSearching: _isSearching,
                                      searchQuery: _searchQuery,
                                      selectedCategoryIndex:
                                          _selectedCategoryIndex,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        CartFloatingButton(
                          onPressed: () => showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => const CartBottomSheet(),
                          ),
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
      ),
    );
  }
}
