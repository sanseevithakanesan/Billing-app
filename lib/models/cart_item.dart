// ============================================
// lib/models/cart_item.dart
// ============================================
import 'product.dart';

class CartItem {
  final Product product;
  int qty;

  CartItem({required this.product, this.qty = 1});

  // ஒவ்வொரு item-ன் total
  double get lineTotal => product.price * qty;

  // JSON format (Invoice save செய்ய)
  Map<String, dynamic> toJson() => {
    'product_id': product.id,
    'qty':        qty,
    'unit_price': product.price,
    'line_total': lineTotal,
  };
}