import 'package:flutter/material.dart';
import 'package:web_ordering/src/core/theme/app_colors.dart';
import 'package:web_ordering/src/features/menu/domain/models/category.dart';

/// Vertical sidebar displaying category list with selection state
class CategorySidebar extends StatelessWidget {
  final List<CategoryModel> categories;
  final int selectedIndex;
  final int? deptId;
  final ValueChanged<int> onCategorySelected;

  const CategorySidebar({
    super.key,
    required this.categories,
    required this.selectedIndex,
    this.deptId,
    required this.onCategorySelected,
  });

  Color get _activeColor => deptId == 2 ? const Color(0xFF4CAF50) : AppColors.primary;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    return Container(
      height: MediaQuery.of(context).size.height * 0.55,
      width: MediaQuery.of(context).size.width * 0.2,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: AppColors.borderLight),
          top: BorderSide(color: AppColors.borderLight),
          bottom: BorderSide(color: AppColors.borderLight),
        ),
      ),
      child: ListView.builder(
        itemCount: categories.length,
        padding: const EdgeInsets.symmetric(vertical: 5),
        itemBuilder: (context, index) {
          final isSelected = selectedIndex == index;
          return GestureDetector(
            onTap: () => onCategorySelected(index),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 0),
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              decoration: BoxDecoration(
                color: isSelected ? _activeColor : Colors.transparent,
              ),
              child: Text(
                categories[index].name,
                style: TextStyle(
                  color: isSelected ? AppColors.textSecondary : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      ),
    );
  }
}
