import 'package:web_ordering/src/features/menu/domain/models/item.dart';

/// Represents a selected customization option
class SelectedCustomization {
  final int groupId;
  final String groupName;
  final int optionId;
  final String optionName;
  final double priceDelta;

  SelectedCustomization({
    required this.groupId,
    required this.groupName,
    required this.optionId,
    required this.optionName,
    required this.priceDelta,
  });
}

/// Cart item model representing an item in the shopping cart
class CartItem {
  final ItemModel item;
  int quantity;
  final List<SelectedCustomization> selectedCustomizations;

  CartItem({
    required this.item,
    required this.quantity,
    this.selectedCustomizations = const [],
  });

  /// Calculate customization total
  double get customizationTotal =>
      selectedCustomizations.fold(0.0, (sum, c) => sum + c.priceDelta);

  /// Calculate base price (item price * quantity)
  double get basePrice => item.price * quantity;

  /// Calculate total price for this cart item (base + customizations)
  double get totalPrice => (item.price + customizationTotal) * quantity;

  /// Create a copy with updated fields
  CartItem copyWith({
    int? quantity,
    List<SelectedCustomization>? selectedCustomizations,
  }) {
    return CartItem(
      item: item,
      quantity: quantity ?? this.quantity,
      selectedCustomizations:
          selectedCustomizations ?? this.selectedCustomizations,
    );
  }
}
