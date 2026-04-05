import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:web_ordering/src/core/routing/app_router.dart';
import 'package:web_ordering/src/core/theme/app_colors.dart';
import 'package:web_ordering/src/features/cart/providers/cart_provider.dart';
import 'package:web_ordering/src/features/cart/data/services/cart_service.dart' as web_ordering_cart_service;

Future<void> showCheckoutDialog(
  BuildContext context,
  CartProvider cart,
  int branchId,
) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _CheckoutDialog(cart: cart, branchId: branchId),
  );
}

class _CheckoutDialog extends StatefulWidget {
  final CartProvider cart;
  final int branchId;

  const _CheckoutDialog({required this.cart, required this.branchId});

  @override
  State<_CheckoutDialog> createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends State<_CheckoutDialog> {
  final _nameController = TextEditingController();
  bool _isLoading = false;
  String? _nameError;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    debugPrint('>>> _submit called');

    final name = _nameController.text.trim();
    debugPrint('>>> name="$name"');

    if (name.isEmpty) {
      setState(() => _nameError = 'Customer name is required');
      return;
    }

    setState(() => _isLoading = true);
    debugPrint('>>> isLoading set, calling submitOrder...');

    try {
      final cartService = web_ordering_cart_service.CartService();
      final orderKey = await cartService.submitOrder(
        customerName: name,
        items: widget.cart.items,
        branchId: widget.branchId,
      );

      debugPrint('>>> submitOrder returned, orderKey="$orderKey"');

      final orderedItems = List.of(widget.cart.items);

      if (!mounted) {
        debugPrint('>>> not mounted after submit, aborting');
        return;
      }

      final nav = Navigator.of(context, rootNavigator: true);
      debugPrint('>>> popping dialog and bottom sheet');
      nav.pop();
      nav.pop();

      await Future.delayed(const Duration(milliseconds: 50));

      widget.cart.clearCart();
      debugPrint('>>> cart cleared, pushing /qr');

      goRouter.push('/qr', extra: {'orderKey': orderKey, 'items': orderedItems});
      debugPrint('>>> goRouter.push done');
    } catch (e, stack) {
      debugPrint('>>> ERROR in _submit: $e');
      debugPrint('>>> STACK: $stack');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = widget.cart;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.shopping_bag_outlined,
              size: 48,
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),
            const Text(
              'Checkout',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '${cart.totalItems} item${cart.totalItems == 1 ? '' : 's'} · ₱${cart.subtotal.toStringAsFixed(2)}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),

            // Order summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              constraints: const BoxConstraints(maxHeight: 150),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: cart.items.length,
                separatorBuilder: (_, __) => Divider(height: 16, color: Colors.grey.shade200),
                itemBuilder: (_, index) {
                  final item = cart.items[index];
                  return Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${item.quantity}x',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      Text(
                        '₱${item.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Total
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '₱${cart.subtotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Name input
            TextField(
              controller: _nameController,
              enabled: !_isLoading,
              textCapitalization: TextCapitalization.words,
              onChanged: (_) {
                if (_nameError != null) setState(() => _nameError = null);
              },
              decoration: InputDecoration(
                labelText: 'Customer Name',
                hintText: 'Enter your name',
                filled: true,
                fillColor: Colors.grey.shade50,
                errorText: _nameError,
                prefixIcon: const Icon(Icons.person_outline, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Colors.red, width: 1.5),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                if (!_isLoading) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
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
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Place Order',
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
  }
}
