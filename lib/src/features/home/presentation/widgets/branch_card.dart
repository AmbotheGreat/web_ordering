import 'package:flutter/material.dart';
import 'package:web_ordering/src/core/theme/app_colors.dart';

/// A card widget displaying a department/branch with its name, image, and
/// selection state. Disabled cards show a "Not Available" overlay.
class BranchCard extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final bool isSelected;
  final bool isAvailable;
  final int? deptId;
  final VoidCallback? onTap;

  const BranchCard({
    super.key,
    required this.name,
    this.imageUrl,
    required this.isSelected,
    this.isAvailable = true,
    this.deptId,
    this.onTap,
  });

  Color get _activeColor => deptId == 2 ? const Color(0xFF4CAF50) : AppColors.primary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isAvailable ? onTap : null,
      child: Opacity(
        opacity: isAvailable ? 1.0 : 0.55,
        child: Stack(
          children: [
            // Base card
            Container(
              width: 100,
              decoration: BoxDecoration(
                color: AppColors.backgroundWhite,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: isSelected ? _activeColor : AppColors.borderMedium,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(13),
                        topRight: Radius.circular(13),
                      ),
                      child: imageUrl != null && imageUrl!.isNotEmpty
                          ? Image.network(
                              imageUrl!,
                              fit: BoxFit.contain,
                              width: double.infinity,
                              errorBuilder: (_, __, ___) => const Icon(Icons.store, size: 36),
                            )
                          : const Center(child: Icon(Icons.store, size: 36)),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? _activeColor : AppColors.backgroundLight,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(13),
                        bottomRight: Radius.circular(13),
                      ),
                    ),
                    child: Text(
                      name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? AppColors.textSecondary : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // "Not Available" overlay
            if (!isAvailable)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Center(
                    child: Text(
                      'Not\nAvailable',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
