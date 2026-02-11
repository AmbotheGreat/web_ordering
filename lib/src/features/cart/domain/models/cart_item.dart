import 'package:web_ordering/src/features/menu/domain/models/item.dart';

/// Cart item model representing an item in the shopping cart
class CartItem {
  final ItemModel item;
  int quantity;

  CartItem({required this.item, required this.quantity});

  /// Calculate total price for this cart item
  double get totalPrice => item.price * quantity;

  /// Create a copy with updated quantity
  CartItem copyWith({int? quantity}) {
    return CartItem(item: item, quantity: quantity ?? this.quantity);
  }
}
