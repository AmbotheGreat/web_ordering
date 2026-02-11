import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:web_ordering/src/core/theme/app_colors.dart';
import 'package:web_ordering/src/features/home/presentation/widgets/branch_card.dart';

/// Header widget for the menu screen containing branch selector and title
class MenuHeader extends StatelessWidget {
  final VoidCallback? onSearchPressed;

  const MenuHeader({super.key, this.onSearchPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 10),
      color: AppColors.backgroundWhite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Select branch :",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          // Branch List
          SizedBox(
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BranchCard(
                  name: "Ana Matcha",
                  assetPath: "",
                  isSelected: false,
                  onTap: () {
                    // TODO: Implement branch selection
                  },
                ),
                BranchCard(
                  name: "Mamonaku",
                  assetPath: "assets/images/mamonaku.png",
                  isSelected: true,
                  onTap: () {
                    // TODO: Implement branch selection
                  },
                ),
                BranchCard(
                  name: "Ceralicious",
                  assetPath: "",
                  isSelected: false,
                  onTap: () {
                    // TODO: Implement branch selection
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
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
                  fontSize: 16,
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
