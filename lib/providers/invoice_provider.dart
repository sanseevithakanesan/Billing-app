import 'package:flutter/material.dart';
import '../models/invoice.dart';
import '../models/cart_item.dart';
import '../services/api_service.dart';

enum InvoiceState { idle, loading, success, error }

class InvoiceProvider extends ChangeNotifier {
  final _api = ApiService();

  List<Invoice> _invoices = [];
  Invoice? _currentInvoice;
  InvoiceState _state = InvoiceState.idle;
  String? _error;

  List<Invoice> get invoices => _invoices;
  Invoice? get currentInvoice => _currentInvoice;
  InvoiceState get state => _state;
  String? get error => _error;
  bool get isLoading => _state == InvoiceState.loading;

 
  Future<Invoice?> createInvoice({
    required int customerId,
    required List<CartItem> cartItems,
    required double taxPercent,
    double discountAmount = 0,
    String? notes,
  }) async {
    _state = InvoiceState.loading;
    _error = null;
    notifyListeners();

    try {
      final items = cartItems
          .map((item) => {
                'product_id': item.product.id,
                'qty': item.qty,
              })
          .toList();

      final response = await _api.post('/invoices', {
        'customer_id': customerId,
        'items': items,
        'tax_percent': taxPercent,
        'discount_amount': discountAmount,
        if (notes != null) 'notes': notes,
      });

      _currentInvoice = Invoice.fromJson(response['invoice']);
      final created = Invoice.fromJson(response['invoice']);
      // final fullData = await _api.get('/invoices/${created.id}');
      // _currentInvoice = Invoice.fromJson(fullData);
      _invoices.insert(0, _currentInvoice!); 
      _state = InvoiceState.success;
      notifyListeners();
      return _currentInvoice;
    } catch (e) {
      _state = InvoiceState.error;
      _error = 'Invoice cannot be created. Please try again.';
      notifyListeners();
      return null;
    }
  }

  // ============================================
  // Load Invoice History
  // ============================================
  Future<void> loadInvoices() async {
    _state = InvoiceState.loading;
    notifyListeners();

    try {
      final data = await _api.get('/invoices');
      final list = data['data'] as List<dynamic>;
      _invoices = list.map((j) => Invoice.fromJson(j)).toList();
      _state = InvoiceState.success;
    } catch (e) {
      _state = InvoiceState.error;
      _error = 'Invoices cannot be loaded. Please try again.';
    }
    notifyListeners();
  }

  // ============================================
  // Update Invoice Status
  // ============================================
  Future<void> updateStatus(int invoiceId, String status) async {
    try {
      await _api.patch('/invoices/$invoiceId/status', {'status': status});
      final index = _invoices.indexWhere((i) => i.id == invoiceId);
      if (index >= 0) {
        // Local update
        _invoices[index] = Invoice.fromJson({
          ..._invoices[index].toJson(),
          'status': status,
        });
        notifyListeners();
      }
    } catch (e) {
      // Error handling
    }
  }

  void reset() {
    _state = InvoiceState.idle;
    _error = null;
    _currentInvoice = null;
    notifyListeners();
  }
}

// Invoice toJson extension
extension InvoiceJson on Invoice {
  Map<String, dynamic> toJson() => {
        'id': id,
        'invoice_no': invoiceNo,
        'customer_id': customerId,
        'customer': customer != null
            ? {
                'id': customer!.id,
                'name': customer!.name,
                'phone': customer!.phone
              }
            : null,
        'items': items
            .map((i) => {
                  'id': i.id,
                  'product_id': i.productId,
                  'product': {'name': i.productName},
                  'qty': i.qty,
                  'unit_price': i.unitPrice,
                  'line_total': i.lineTotal,
                })
            .toList(),
        'subtotal': subtotal,
        'tax_percent': taxPercent,
        'tax_amount': taxAmount,
        'discount_amount': discountAmount,
        'total': total,
        'status': status,
        'notes': notes,
        'created_at': createdAt,
      };
}
