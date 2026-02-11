import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:web_ordering/src/core/theme/app_colors.dart';
import 'package:web_ordering/src/features/menu/domain/models/item.dart';
import 'package:web_ordering/src/features/menu/domain/models/product_customization.dart';
import 'package:web_ordering/src/features/menu/presentation/bloc/product_customization_bloc.dart';
import 'package:web_ordering/src/features/home/presentation/widgets/quantity_selector.dart';
import 'package:web_ordering/src/features/cart/providers/cart_provider.dart';

/// Item details screen showing full information and add to cart functionality
class ItemDetailsScreen extends StatefulWidget {
  final ItemModel item;

  const ItemDetailsScreen({super.key, required this.item});

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  int _quantity = 1;

  double get _totalPrice => widget.item.price * _quantity;

  @override
  void initState() {
    super.initState();
    // Fetch customizations when screen loads if item has barcode
    if (widget.item.barcode != null && widget.item.barcode!.isNotEmpty) {
      context.read<ProductCustomizationBloc>().add(
        FetchProductCustomization(
          barcode: widget.item.barcode!,
          branchId: widget.item.branchId,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Item Details',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Item Image
                    Center(
                      child: Container(
                        width: double.infinity,
                        height: 300,
                        decoration: BoxDecoration(color: Colors.black12),
                        child: _buildItemImage(),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Item Name
                    Text(
                      widget.item.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    // Item Description
                    Text(
                      "Indulge in our Signature Pearl Milk Tea, a perfect harmony of premium, slow-brewed black tea and creamy, smooth milk. Perfectly balanced with just the right amount of sweetness, this classic favorite is served with our signature chewy, brown sugar tapioca pearls. A comforting classic you'll crave over and over again.",
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Product Customizations Section (On-Demand)
                    if (widget.item.barcode != null &&
                        widget.item.barcode!.isNotEmpty)
                      BlocBuilder<
                        ProductCustomizationBloc,
                        ProductCustomizationState
                      >(
                        builder: (context, state) {
                          if (state is ProductCustomizationLoading) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),
                              ),
                            );
                          } else if (state is ProductCustomizationLoaded &&
                              state.customizations.isNotEmpty) {
                            return Column(
                              children: _buildCustomizationsSection(
                                state.customizations,
                              ),
                            );
                          } else if (state is ProductCustomizationError) {
                            // Silently fail - show nothing if error
                            return const SizedBox.shrink();
                          }
                          return const SizedBox.shrink();
                        },
                      ),

                    const SizedBox(height: 12),

                    // Price
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black.withValues(alpha: 0.5),
                                width: 1,
                              ),
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: QuantitySelector(
                              quantity: _quantity,
                              onQuantityChanged: (newQuantity) {
                                setState(() => _quantity = newQuantity);
                              },
                            ),
                          ),
                          Text(
                            '₱${widget.item.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),

          // Add to Cart Button
          Container(
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
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total :',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '₱${_totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  spacing: 10,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          context.go('/menu');
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          side: BorderSide(color: Colors.black, width: 1),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _addToCart,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textSecondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Add to Cart',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
  }

  List<Widget> _buildCustomizationsSection(
    List<ProductCustomizationModel> customizations,
  ) {
    return [
      const SizedBox(height: 20),
      const Text(
        'Customizations',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      const SizedBox(height: 12),
      ...customizations.map((customization) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                customization.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (customization.description != null &&
                  customization.description!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  customization.description!,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
              const SizedBox(height: 12),
              ...customization.options.map((option) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          option.name,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (option.price != null && option.price! > 0)
                        Text(
                          '+₱${option.price!.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      }),
    ];
  }

  Widget _buildItemImage() {
    if (widget.item.imageUrl != null && widget.item.imageUrl!.isNotEmpty) {
      return Image.network(
        widget.item.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.coffee, size: 100, color: AppColors.textSecondary),
      );
    }
    return const Icon(Icons.coffee, size: 100, color: AppColors.textSecondary);
  }

  void _addToCart() {
    // Add to cart using provider
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.addToCart(widget.item, _quantity);

    // Show success notification with toastification
    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: ToastificationStyle.fillColored,
      title: const Text('Added to cart!'),
      alignment: Alignment.topCenter,
      autoCloseDuration: const Duration(seconds: 2),
      primaryColor: const Color.fromARGB(255, 36, 217, 42),
      backgroundColor: const Color.fromARGB(255, 1, 255, 9),
      foregroundColor: Colors.white,
      icon: const Icon(Icons.check_circle),
      showProgressBar: true,
      closeButtonShowType: CloseButtonShowType.onHover,
      closeOnClick: true,
      pauseOnHover: true,
      dragToClose: true,
      applyBlurEffect: false,
    );

    // Navigate back to menu after adding to cart
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }
}
