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
import 'package:web_ordering/src/features/home/presentation/widgets/customization_selector.dart';
import 'package:web_ordering/src/features/cart/providers/cart_provider.dart';
import 'package:web_ordering/src/features/cart/domain/models/cart_item.dart';

/// Item details screen showing full information and add to cart functionality
class ItemDetailsScreen extends StatefulWidget {
  final ItemModel item;

  const ItemDetailsScreen({super.key, required this.item});

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  int _quantity = 1;
  List<ProductCustomizationModel> _customizations = [];
  final Map<int, List<int>> _selectedCustomizations =
      {}; // {groupId: [optionIds]}
  Set<int> _errorCustomizationIds = {};

  double get _customizationTotal {
    double total = 0.0;
    for (var entry in _selectedCustomizations.entries) {
      final groupId = entry.key;
      final optionIds = entry.value;
      final group = _customizations.firstWhere((c) => c.id == groupId);
      for (var optionId in optionIds) {
        final option = group.options.firstWhere((o) => o.id == optionId);
        total += option.price ?? 0.0;
      }
    }
    return total;
  }

  double get _totalPrice =>
      (widget.item.price + _customizationTotal) * _quantity;

  @override
  void initState() {
    super.initState();
    // Fetch customizations when screen loads if item has barcode
    // Use WidgetsBinding to ensure context is ready
    if (widget.item.barcode != null && widget.item.barcode!.isNotEmpty) {
      print('📱 ItemDetailsScreen: Item has barcode: ${widget.item.barcode}');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        print('🚀 Triggering FetchProductCustomization event');
        context.read<ProductCustomizationBloc>().add(
          FetchProductCustomization(
            barcode: widget.item.barcode!,
            branchId: widget.item.branchId,
          ),
        );
      });
    } else {
      print('⚠️ ItemDetailsScreen: Item has no barcode');
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
                          print('🎨 BlocBuilder state: ${state.runtimeType}');

                          if (state is ProductCustomizationLoading) {
                            print('⏳ Showing loading indicator');
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),
                              ),
                            );
                          } else if (state is ProductCustomizationLoaded) {
                            if (state.customizations.isEmpty) {
                              print(
                                '⚠️ ProductCustomizationLabel: Loaded but empty list',
                              );
                              return const SizedBox.shrink();
                            }

                            print(
                              '✅ Showing ${state.customizations.length} customizations',
                            );

                            // Update customizations state
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (_customizations != state.customizations) {
                                Future.microtask(() {
                                  if (mounted) {
                                    setState(() {
                                      _customizations = state.customizations;
                                    });
                                  }
                                });
                              }
                            });

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 20,
                              children: state.customizations.map((
                                customization,
                              ) {
                                return CustomizationSelector(
                                  customization: customization,
                                  hasError: _errorCustomizationIds.contains(
                                    customization.id,
                                  ),
                                  onSelectionChanged: (selectedOptionIds) {
                                    // If user makes a selection, remove error state
                                    if (_errorCustomizationIds.contains(
                                          customization.id,
                                        ) &&
                                        selectedOptionIds.isNotEmpty) {
                                      setState(() {
                                        _errorCustomizationIds.remove(
                                          customization.id,
                                        );
                                      });
                                    }

                                    setState(() {
                                      if (selectedOptionIds.isEmpty) {
                                        _selectedCustomizations.remove(
                                          customization.id,
                                        );
                                      } else {
                                        _selectedCustomizations[customization
                                                .id] =
                                            selectedOptionIds;
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            );
                          } else if (state is ProductCustomizationError) {
                            print('❌ Error state: ${state.message}');
                            // Silently fail - show nothing if error
                            return const SizedBox.shrink();
                          }
                          print('🔲 Showing nothing (initial or empty state)');
                          return const SizedBox.shrink();
                        },
                      ),

                    const SizedBox(height: 12),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black.withValues(alpha: 0.5),
                              width: 1,
                            ),
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: QuantitySelector(
                            quantity: _quantity,
                            onQuantityChanged: (newQuantity) {
                              setState(() => _quantity = newQuantity);
                            },
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '₱${_totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
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

  void _addToCart() {
    // Validate required customizations
    final Set<int> newErrors = {};

    for (var customization in _customizations) {
      if (customization.isRequired) {
        if (!_selectedCustomizations.containsKey(customization.id) ||
            _selectedCustomizations[customization.id]!.isEmpty) {
          newErrors.add(customization.id);
        }
      }
    }

    if (newErrors.isNotEmpty) {
      setState(() {
        _errorCustomizationIds = newErrors;
      });
      return;
    }

    // Clear errors if validation passes
    if (_errorCustomizationIds.isNotEmpty) {
      setState(() {
        _errorCustomizationIds.clear();
      });
    }

    // Build SelectedCustomization list
    final List<SelectedCustomization> selectedCustomizations = [];
    for (var entry in _selectedCustomizations.entries) {
      final groupId = entry.key;
      final optionIds = entry.value;
      final group = _customizations.firstWhere((c) => c.id == groupId);

      for (var optionId in optionIds) {
        final option = group.options.firstWhere((o) => o.id == optionId);
        selectedCustomizations.add(
          SelectedCustomization(
            groupId: group.id,
            groupName: group.name,
            optionId: option.id,
            optionName:
                (group.name.toLowerCase().contains('sugar')) &&
                    double.tryParse(option.name) != null
                ? '${option.name}%'
                : option.name,
            priceDelta: option.price ?? 0.0,
            barcode: option.barcode, // Added barcode mapping
          ),
        );
      }
    }

    // Add to cart
    context.read<CartProvider>().addToCart(
      widget.item,
      _quantity,
      customizations: selectedCustomizations,
    );

    // Show success toast
    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: ToastificationStyle.fillColored,
      title: const Text('Added to Cart'),
      description: Text('${widget.item.name} has been added to your cart'),
      autoCloseDuration: const Duration(seconds: 2),
      alignment: Alignment.topCenter,
    );

    // Navigate back
    context.go('/menu');
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
}
