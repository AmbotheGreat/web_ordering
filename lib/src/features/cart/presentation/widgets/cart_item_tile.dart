import 'package:flutter/material.dart';
import 'package:web_ordering/src/core/theme/app_colors.dart';
import 'package:web_ordering/src/features/cart/domain/models/cart_item.dart';

class CartItemTile extends StatelessWidget {
  final CartItem cartItem;
  final ValueChanged<int> onQuantityChanged;

  const CartItemTile({
    super.key,
    required this.cartItem,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          _buildImage(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cartItem.item.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (cartItem.selectedCustomizations.isNotEmpty) ...[
                  ..._buildCustomizationRows(),
                  const SizedBox(height: 4),
                ],
                _buildQuantityRow(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    final hasImage =
        cartItem.item.imageUrl != null && cartItem.item.imageUrl!.isNotEmpty;

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: hasImage
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                cartItem.item.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.coffee,
                  size: 30,
                  color: AppColors.textSecondary,
                ),
              ),
            )
          : const Icon(
              Icons.coffee,
              size: 30,
              color: AppColors.textSecondary,
            ),
    );
  }

  List<Widget> _buildCustomizationRows() {
    final grouped = <String, int>{};
    final distinct = <String, SelectedCustomization>{};

    for (var custom in cartItem.selectedCustomizations) {
      final key = '${custom.groupId}_${custom.optionId}';
      grouped[key] = (grouped[key] ?? 0) + 1;
      distinct[key] = custom;
    }

    return distinct.keys.map((key) {
      return _buildCustomizationRow(distinct[key]!, grouped[key]!);
    }).toList();
  }

  Widget _buildCustomizationRow(
    SelectedCustomization customization,
    int count,
  ) {
    final optionText = count > 1
        ? '${customization.optionName} (x$count)'
        : customization.optionName;

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 4, color: Colors.grey),
          const SizedBox(width: 6),
          Expanded(
            child: RichText(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                children: [
                  TextSpan(
                    text: '${customization.groupName}: ',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: optionText),
                ],
              ),
            ),
          ),
          if (customization.priceDelta > 0)
            Text(
              '+₱${(customization.priceDelta * count).toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuantityRow() {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderLight),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _QuantityButton(
                icon: Icons.remove,
                onPressed: () => onQuantityChanged(cartItem.quantity - 1),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '${cartItem.quantity}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _QuantityButton(
                icon: Icons.add,
                onPressed: () => onQuantityChanged(cartItem.quantity + 1),
              ),
            ],
          ),
        ),
        const Spacer(),
        Text(
          '₱${cartItem.totalPrice.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _QuantityButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 16, color: AppColors.primary),
      ),
    );
  }
}
