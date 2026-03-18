
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/cart_item.dart';

class CartProvider extends ChangeNotifier {
  // ─── State ─────────────────────────────────
  final List<CartItem> _items = [];
  double _taxPercent = 5.0; // Default 5% GST
  double _discountAmount = 0.0;

  // ─── Getters ───────────────────────────────
  List<CartItem> get items        => List.unmodifiable(_items);
  int get itemCount               => _items.length;
  int get totalQty                => _items.fold(0, (sum, i) => sum + i.qty);
  double get taxPercent           => _taxPercent;
  double get discountAmount       => _discountAmount;

  // ─── Calculation Formula ───────────────────
  //
  //  subtotal = Σ (price × qty)        per item
  //  taxAmount = subtotal × (tax / 100)
  //  grandTotal = subtotal + tax - discount
  //
  double get subtotal {
    return _items.fold(0.0, (sum, item) => sum + item.lineTotal);
  }

  double get taxAmount {
    return subtotal * (_taxPercent / 100);
  }

  double get grandTotal {
    final total = subtotal + taxAmount - _discountAmount;
    return total < 0 ? 0 : total;
  }

  double get savings {
    return _discountAmount;
  }

  // ─── Add Product ───────────────────────────
  void addProduct(Product product, {int qty = 1}) {
    final index = _items.indexWhere((i) => i.product.id == product.id);
    if (index >= 0) {
      _items[index].qty += qty;
    } else {
      _items.add(CartItem(product: product, qty: qty));
    }
    notifyListeners();
  }

  // ─── Increase Qty ──────────────────────────
  void increaseQty(int productId) {
    final index = _items.indexWhere((i) => i.product.id == productId);
    if (index >= 0) {
      _items[index].qty++;
      notifyListeners();
    }
  }

  // ─── Decrease Qty ──────────────────────────
  void decreaseQty(int productId) {
    final index = _items.indexWhere((i) => i.product.id == productId);
    if (index >= 0) {
      if (_items[index].qty > 1) {
        _items[index].qty--;
      } else {
        _items.removeAt(index); // qty 0 → remove
      }
      notifyListeners();
    }
  }

  // ─── Set Exact Qty ─────────────────────────
  void setQty(int productId, int qty) {
    if (qty <= 0) {
      removeItem(productId);
      return;
    }
    final index = _items.indexWhere((i) => i.product.id == productId);
    if (index >= 0) {
      _items[index].qty = qty;
      notifyListeners();
    }
  }

  // ─── Remove Product ────────────────────────
  void removeItem(int productId) {
    _items.removeWhere((i) => i.product.id == productId);
    notifyListeners();
  }

  // ─── Set Tax % ─────────────────────────────
  void setTax(double percent) {
    _taxPercent = percent.clamp(0, 100);
    notifyListeners();
  }

  // ─── Set Discount ──────────────────────────
  void setDiscount(double amount) {
    _discountAmount = amount.clamp(0, subtotal);
    notifyListeners();
  }

  // ─── Clear Cart ────────────────────────────
  void clearCart() {
    _items.clear();
    _discountAmount = 0;
    notifyListeners();
  }

 
  List<Map<String, dynamic>> toInvoiceItems() {
    return _items.map((i) => i.toJson()).toList();
  }

 
  bool contains(int productId) {
    return _items.any((i) => i.product.id == productId);
  }


  int getQty(int productId) {
    final item = _items.where((i) => i.product.id == productId);
    return item.isNotEmpty ? item.first.qty : 0;
  }
}