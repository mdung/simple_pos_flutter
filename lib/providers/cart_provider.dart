import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];
  double _discount = 0.0;

  List<CartItem> get items => _items;
  double get discount => _discount;

  double get subtotal {
    return _items.fold<double>(0.0, (sum, item) => sum + item.subtotal);
  }

  double get total {
    return subtotal - _discount;
  }

  int get itemCount {
    return _items.fold<int>(0, (sum, item) => sum + item.quantity);
  }

  bool get isEmpty => _items.isEmpty;

  void addItem(Product product, {int quantity = 1}) {
    if (product.stock < quantity) {
      throw Exception('Insufficient stock');
    }

    final existingIndex = _items.indexWhere((item) => item.product.id == product.id);
    if (existingIndex >= 0) {
      final existingItem = _items[existingIndex];
      final newQuantity = existingItem.quantity + quantity;
      if (newQuantity > product.stock) {
        throw Exception('Insufficient stock');
      }
      _items[existingIndex] = existingItem.copyWith(quantity: newQuantity);
    } else {
      _items.add(CartItem(product: product, quantity: quantity));
    }
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }

    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      final item = _items[index];
      if (quantity > item.product.stock) {
        throw Exception('Insufficient stock');
      }
      _items[index] = item.copyWith(quantity: quantity);
      notifyListeners();
    }
  }

  void removeItem(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void setDiscount(double discount) {
    _discount = discount;
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _discount = 0.0;
    notifyListeners();
  }
}

