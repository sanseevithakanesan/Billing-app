import 'customer.dart';
import 'invoice_item.dart';

class Invoice {
  final int id;
  final String invoiceNo;
  final int customerId;
  final Customer? customer;
  final List<InvoiceItem> items;
  final double subtotal;
  final double taxPercent;
  final double taxAmount;
  final double discountAmount;
  final double total;
  final String status; // paid | unpaid | cancelled
  final String? notes;
  final String createdAt;

  Invoice({
    required this.id,
    required this.invoiceNo,
    required this.customerId,
    this.customer,
    required this.items,
    required this.subtotal,
    required this.taxPercent,
    required this.taxAmount,
    required this.discountAmount,
    required this.total,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id:             json['id'],
      invoiceNo:      json['invoice_no'],
      customerId:     json['customer_id'],
      customer:       json['customer'] != null
          ? Customer.fromJson(json['customer'])
          : null,
      items:          json['items'] != null
          ? (json['items'] as List)
              .map((i) => InvoiceItem.fromJson(i))
              .toList()
          : [],
      subtotal:       double.parse(json['subtotal'].toString()),
      taxPercent:     double.parse(json['tax_percent'].toString()),
      taxAmount:      double.parse(json['tax_amount'].toString()),
      discountAmount: double.parse(json['discount_amount'].toString()),
      total:          double.parse(json['total'].toString()),
      status:         json['status'],
      notes:          json['notes'],
      createdAt:      json['created_at'],
    );
  }
}

// lib/models/invoice_item.dart
class InvoiceItem {
  final int id;
  final int productId;
  final String productName;
  final int qty;
  final double unitPrice;
  final double lineTotal;

  InvoiceItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.qty,
    required this.unitPrice,
    required this.lineTotal,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      id:          json['id'],
      productId:   json['product_id'],
      productName: json['product']?['name'] ?? 'Unknown',
      qty:         json['qty'],
      unitPrice:   double.parse(json['unit_price'].toString()),
      lineTotal:   double.parse(json['line_total'].toString()),
    );
  }
}

// lib/models/customer.dart
class Customer {
  final int id;
  final String name;
  final String phone;
  final String? email;
  final String? address;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.address,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id:      json['id'],
      name:    json['name'],
      phone:   json['phone'],
      email:   json['email'],
      address: json['address'],
    );
  }
}