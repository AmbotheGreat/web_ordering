import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_ordering/src/core/theme/app_colors.dart';
import 'package:web_ordering/src/features/cart/providers/cart_provider.dart';
import 'package:web_ordering/src/features/cart/data/services/cart_service.dart'
    as web_ordering_cart_service;
import 'package:go_router/go_router.dart';

/// Bottom sheet widget displaying cart contents
class CartBottomSheet extends StatelessWidget {
  const CartBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
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
                  // Drag Handle
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Header
                  Padding(
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
                            onPressed: () {
                              cart.clearCart();
                            },
                            child: const Text(
                              'Clear all',
                              style: TextStyle(color: AppColors.error),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Content
                  Expanded(
                    child: cart.items.isEmpty
                        ? _buildEmptyCart(context)
                        : _buildCartList(context, cart, scrollController),
                  ),
                  // Checkout Bar
                  if (cart.items.isNotEmpty) _buildCheckoutBar(context, cart),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.grey[300],
          ),
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

  Widget _buildCartList(
    BuildContext context,
    CartProvider cart,
    ScrollController scrollController,
  ) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: cart.items.length,
      itemBuilder: (context, index) {
        final cartItem = cart.items[index];
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
              // Item Image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    cartItem.item.imageUrl != null &&
                        cartItem.item.imageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          cartItem.item.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
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
              ),
              const SizedBox(width: 12),
              // Item Details
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
                    // Display customizations if any
                    if (cartItem.selectedCustomizations.isNotEmpty) ...[
                      ...cartItem.selectedCustomizations.map((customization) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.circle,
                                size: 4,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: RichText(
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                    ),
                                    children: [
                                      TextSpan(
                                        text: '${customization.groupName}: ',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      TextSpan(text: customization.optionName),
                                    ],
                                  ),
                                ),
                              ),
                              if (customization.priceDelta > 0)
                                Text(
                                  '+₱${customization.priceDelta.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 4),
                    ],
                    Row(
                      children: [
                        // Quantity controls
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.borderLight),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildQuantityButton(
                                icon: Icons.remove,
                                onPressed: () {
                                  cart.updateQuantity(
                                    cartItem.item.id,
                                    cartItem.quantity - 1,
                                  );
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Text(
                                  '${cartItem.quantity}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              _buildQuantityButton(
                                icon: Icons.add,
                                onPressed: () {
                                  cart.updateQuantity(
                                    cartItem.item.id,
                                    cartItem.quantity + 1,
                                  );
                                },
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
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 16, color: AppColors.primary),
      ),
    );
  }

  Widget _buildCheckoutBar(BuildContext context, CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Items ',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          Text(
                            '${cart.totalItems}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          Text(
                            '₱${cart.subtotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _showCheckoutDialog(context, cart),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textSecondary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Checkout',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCheckoutDialog(
    BuildContext parentContext,
    CartProvider cart,
  ) async {
    final nameController = TextEditingController();
    bool isLoading = false;
    String? nameError;

    await showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (stateContext, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(dialogContext).colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title and Subtitle
                    const Text(
                      'Proceed to Checkout',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Please enter your name for the order:',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 24),

                    // Name field with inline validation
                    TextField(
                      controller: nameController,
                      enabled: !isLoading,
                      textCapitalization: TextCapitalization.words,
                      onChanged: (_) {
                        if (nameError != null) setState(() => nameError = null);
                      },
                      decoration: InputDecoration(
                        labelText: 'Customer Name',
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        errorText: nameError,
                        prefixIcon: const Icon(
                          Icons.person,
                          color: Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Theme.of(dialogContext).primaryColor,
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 1.5,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Balanced Action Buttons
                    Row(
                      children: [
                        if (!isLoading) ...[
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                side: BorderSide(color: Colors.grey.shade300),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    final name = nameController.text.trim();
                                    if (name.isEmpty) {
                                      setState(() {
                                        nameError = 'Customer name is required';
                                      });
                                      return;
                                    }

                                    setState(() {
                                      isLoading = true;
                                    });

                                    try {
                                      // Let the service handle device OS detection and Supabase networking
                                      final cartService =
                                          web_ordering_cart_service.CartService();
                                      final orderKey = await cartService
                                          .submitOrder(
                                            customerName: name,
                                            items: cart.items,
                                          );

                                      print(
                                        '=== NAVIGATION: orderKey="$orderKey" ===',
                                      );

                                      // Snapshot items BEFORE clearing the cart
                                      final orderedItems = List.of(cart.items);
                                      cart.clearCart();

                                      // Capture the router BEFORE popping to avoid
                                      // using an unmounted context after navigation.
                                      final router = GoRouter.of(parentContext);

                                      if (dialogContext.mounted) {
                                        Navigator.pop(
                                          dialogContext,
                                        ); // Close dialog
                                      }
                                      if (parentContext.mounted) {
                                        Navigator.pop(
                                          parentContext,
                                        ); // Close bottom sheet
                                      }

                                      // Navigate using the router captured before pops.
                                      if (orderKey.isNotEmpty) {
                                        router.push(
                                          '/qr',
                                          extra: {
                                            'orderKey': orderKey,
                                            'items': orderedItems,
                                          },
                                        );
                                      } else {
                                        // orderKey extraction failed — still show success
                                        ScaffoldMessenger.of(
                                          parentContext,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Order submitted successfully!',
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      print('=== ORDER ERROR CAUGHT ===');
                                      print(e.toString());
                                      setState(() {
                                        isLoading = false;
                                      });
                                      if (stateContext.mounted) {
                                        ScaffoldMessenger.of(
                                          stateContext,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Error: ${e.toString()}',
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Submit Order',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
