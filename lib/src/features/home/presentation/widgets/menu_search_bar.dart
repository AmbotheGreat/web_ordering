import 'package:flutter/material.dart';
import 'package:web_ordering/src/core/theme/app_colors.dart';

/// A styled search bar for filtering menu items.
class MenuSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String query;
  final int? deptId;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const MenuSearchBar({
    super.key,
    required this.controller,
    required this.query,
    this.deptId,
    required this.onChanged,
    required this.onClear,
  });

  Color get _activeColor =>
      deptId == 2 ? const Color(0xFF4CAF50) : AppColors.primary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Search menu items...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: query.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: onClear,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _activeColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _activeColor),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
