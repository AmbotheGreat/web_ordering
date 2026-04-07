import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:web_ordering/src/core/theme/app_colors.dart';

/// Header widget for the menu screen containing the logo and title row.
class MenuHeader extends StatelessWidget {
  final VoidCallback? onSearchPressed;

  const MenuHeader({
    super.key,
    this.onSearchPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      color: const Color.fromARGB(255, 255, 255, 255),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PC Logo
          Center(
            child: Image.asset(
              'assets/images/pc_logo.png',
              height: 100,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 10),
          // Title Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                onPressed: () => context.go('/'),
              ),
              const Text(
                'Explore Our Menu',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(10),
                ),
                icon: const Icon(
                  Icons.search,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                onPressed: onSearchPressed ?? () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
