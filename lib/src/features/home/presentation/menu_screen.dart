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
  int? _selectedDeptId;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _branchIdFromState() {
    final state = context.read<MasterBloc>().state;
    if (state is MasterLoaded) return state.branchId;
    if (state is MasterMenuLoading) return state.branchId;
    return 0;
  }

  void _selectDepartment(int deptId) {
    if (_selectedDeptId == deptId) return;

    _selectedCategoryIndex = 0;
    setState(() {
      _selectedDeptId = deptId;
      _isSearching = false;
      _searchController.clear();
      _searchQuery = '';
    });

    final branchId = _branchIdFromState();
    if (branchId == 0) return;

    context.read<MasterBloc>().add(
      FetchMasterData(branchId: branchId, departmentId: deptId),
    );
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
        child: BlocListener<MasterBloc, MasterState>(
          // Auto-select the first department when departments first load
          listenWhen: (prev, curr) => curr is MasterLoaded && curr.departments.isNotEmpty && _selectedDeptId == null,
          listener: (context, state) {
            if (state is MasterLoaded && state.departments.isNotEmpty) {
              _selectDepartment(state.departments.first.id);
            }
          },
          child: Column(
            children: [
              MenuHeader(
                onSearchPressed: _toggleSearch,
                selectedBranchId: _selectedDeptId,
                onBranchSelected: _selectDepartment,
              ),
              if (_isSearching)
                MenuSearchBar(
                  controller: _searchController,
                  query: _searchQuery,
                  deptId: _selectedDeptId,
                  onChanged: (value) => setState(() => _searchQuery = value.trim().toLowerCase()),
                  onClear: () => setState(() {
                    _searchController.clear();
                    _searchQuery = '';
                  }),
                ),
              const Divider(height: 1),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_selectedDeptId == null) {
      return const Center(
        child: Text(
          'Please select a department to view the menu.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return BlocBuilder<MasterBloc, MasterState>(
      builder: (context, state) {
        // Loading menu data (departments already shown in header)
        if (state is MasterMenuLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is MasterLoading || state is MasterInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is MasterError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Error: ${state.message}'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    final branchId = _branchIdFromState();
                    if (branchId != 0 && _selectedDeptId != null) {
                      context.read<MasterBloc>().add(
                        FetchMasterData(
                          branchId: branchId,
                          departmentId: _selectedDeptId!,
                        ),
                      );
                    }
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is MasterLoaded && state.categories.isNotEmpty) {
          final safeIndex = _selectedCategoryIndex.clamp(
            0,
            state.categories.length - 1,
          );

          return Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!_isSearching)
                    CategorySidebar(
                      categories: state.categories,
                      selectedIndex: safeIndex,
                      deptId: _selectedDeptId,
                      onCategorySelected: (index) => setState(() => _selectedCategoryIndex = index),
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
                            _isSearching ? 'All Items' : state.categories[safeIndex].name,
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
                            selectedCategoryIndex: safeIndex,
                            deptId: _selectedDeptId,
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

        // MasterLoaded but categories empty for this department
        return const Center(
          child: Text(
            'No categories found for this department.',
            style: TextStyle(color: Colors.grey),
          ),
        );
      },
    );
  }
}
