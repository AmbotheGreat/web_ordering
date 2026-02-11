import 'package:flutter/material.dart';
import 'package:web_ordering/src/core/theme/app_colors.dart';

/// A reusable quantity selector widget with increase and decrease buttons
class QuantitySelector extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onQuantityChanged;
  final int minQuantity;
  final int maxQuantity;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onQuantityChanged,
    this.minQuantity = 1,
    this.maxQuantity = 99,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildButton(
          icon: Icons.remove,
          onPressed: quantity > minQuantity
              ? () => onQuantityChanged(quantity - 1)
              : null,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Text(
            quantity.toString(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        _buildButton(
          icon: Icons.add,
          onPressed: quantity < maxQuantity
              ? () => onQuantityChanged(quantity + 1)
              : null,
        ),
      ],
    );
  }

  Widget _buildButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: onPressed != null ? AppColors.primary : AppColors.borderLight,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon),
        color: AppColors.textSecondary,
        onPressed: onPressed,
        padding: const EdgeInsets.all(4),
        constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
      ),
    );
  }
}
