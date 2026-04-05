import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_ordering/src/core/theme/app_colors.dart';
import 'package:web_ordering/src/features/cart/providers/cart_provider.dart';
import 'package:web_ordering/src/features/cart/presentation/widgets/cart_item_tile.dart';
import 'package:web_ordering/src/features/cart/presentation/widgets/cart_checkout_bar.dart';
import 'package:web_ordering/src/features/cart/presentation/widgets/checkout_dialog.dart';

class CartBottomSheet extends StatelessWidget {
  final int branchId;

  const CartBottomSheet({super.key, required this.branchId});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.backgroundWhite,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  _buildDragHandle(),
                  _buildHeader(cart),
                  const Divider(height: 1),
                  Expanded(
                    child: cart.items.isEmpty ? _buildEmptyState() : _buildItemList(cart, scrollController),
                  ),
                  if (cart.items.isNotEmpty)
                    CartCheckoutBar(
                      totalItems: cart.totalItems,
                      subtotal: cart.subtotal,
                      onCheckout: () => showCheckoutDialog(context, cart, branchId),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDragHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(CartProvider cart) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'My Cart',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          if (cart.items.isNotEmpty)
            TextButton(
              onPressed: cart.clearCart,
              child: const Text(
                'Clear all',
                style: TextStyle(color: AppColors.error),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add items to get started',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildItemList(CartProvider cart, ScrollController scrollController) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: cart.items.length,
      itemBuilder: (_, index) {
        final cartItem = cart.items[index];
        return CartItemTile(
          cartItem: cartItem,
          onQuantityChanged: (qty) => cart.updateQuantity(cartItem.item.id, qty),
        );
      },
    );
  }
}
