import 'package:flutter/foundation.dart';
import 'package:web_ordering/src/features/cart/domain/models/cart_item.dart';
import 'package:web_ordering/src/features/menu/domain/models/item.dart';

/// Cart provider for managing cart state
class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  /// Get all cart items
  List<CartItem> get items => List.unmodifiable(_items);

  /// Get total number of items in cart
  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);

  /// Get cart subtotal
  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  /// Check if an item is in the cart
  bool isInCart(int itemId) {
    return _items.any((cartItem) => cartItem.item.id == itemId);
  }

  /// Get quantity of a specific item in cart
  int getItemQuantity(int itemId) {
    try {
      final cartItem = _items.firstWhere((item) => item.item.id == itemId);
      return cartItem.quantity;
    } catch (e) {
      return 0;
    }
  }

  /// Add item to cart or update quantity if already exists
  void addToCart(
    ItemModel item,
    int quantity, {
    List<SelectedCustomization> customizations = const [],
  }) {
    final existingIndex = _items.indexWhere(
      (cartItem) => cartItem.item.id == item.id,
    );

    if (existingIndex >= 0) {
      // Item already in cart, update quantity
      _items[existingIndex].quantity += quantity;
    } else {
      // New item, add to cart
      _items.add(
        CartItem(
          item: item,
          quantity: quantity,
          selectedCustomizations: customizations,
        ),
      );
    }

    notifyListeners();
  }

  /// Remove item from cart
  void removeFromCart(int itemId) {
    _items.removeWhere((cartItem) => cartItem.item.id == itemId);
    notifyListeners();
  }

  /// Update item quantity
  void updateQuantity(int itemId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(itemId);
      return;
    }

    final index = _items.indexWhere((cartItem) => cartItem.item.id == itemId);

    if (index >= 0) {
      _items[index].quantity = quantity;
      notifyListeners();
    }
  }

  /// Clear all items from cart
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
