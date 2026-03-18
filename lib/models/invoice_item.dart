
class InvoiceItem {
  final int id;
  final int invoiceId;
  final int productId;
  final String productName;
  final int qty;
  final double unitPrice;
  final double lineTotal;

  InvoiceItem({
    required this.id,
    required this.invoiceId,
    required this.productId,
    required this.productName,
    required this.qty,
    required this.unitPrice,
    required this.lineTotal,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      id:          json['id'] ?? 0,
      invoiceId:   json['invoice_id'] ?? 0,
      productId:   json['product_id'] ?? 0,
      productName: json['product']?['name'] ?? 'Unknown Product',
      qty:         json['qty'] ?? 0,
      unitPrice:   double.parse(json['unit_price'].toString()),
      lineTotal:   double.parse(json['line_total'].toString()),
    );
  }

  Map<String, dynamic> toJson() => {
    'id':           id,
    'invoice_id':   invoiceId,
    'product_id':   productId,
    'product':      {'name': productName},
    'qty':          qty,
    'unit_price':   unitPrice,
    'line_total':   lineTotal,
  };
}