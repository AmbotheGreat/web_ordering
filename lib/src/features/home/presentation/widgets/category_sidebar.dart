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
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Wrap(
          spacing: 8,
          children: List.generate(categories.length, (index) {
            final isSelected = selectedIndex == index;
            return GestureDetector(
              onTap: () => onCategorySelected(index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected ? _activeColor : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? _activeColor : AppColors.borderLight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  categories[index].name,
                  style: TextStyle(
                    color: isSelected ? AppColors.textSecondary : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
