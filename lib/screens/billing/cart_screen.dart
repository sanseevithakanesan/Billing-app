// lib/screens/billing/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/invoice_provider.dart';
import '../../models/cart_item.dart';
import '../../models/customer.dart';
import '../../services/api_service.dart';
import '../invoices/invoice_detail_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _api = ApiService();
  List<Customer> _customers = [];
  Customer? _selectedCustomer;
  bool _loadingCustomers = false;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  // ── Customers load ──────────────────────────
  Future<void> _loadCustomers() async {
    setState(() => _loadingCustomers = true);
    try {
      final data = await _api.get('/customers');
      setState(() {
        _customers = (data as List<dynamic>)
            .map((j) => Customer.fromJson(j as Map<String, dynamic>))
            .toList();
        _loadingCustomers = false;
      });
    } catch (e) {
      setState(() => _loadingCustomers = false);
    }
  }

  // ── Invoice create ──────────────────────────
  Future<void> _createInvoice() async {
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Customer select செய்யுங்கள்!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final cart = context.read<CartProvider>();
    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cart காலியாக இருக்கிறது!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Loading
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(children: [
          SizedBox(
            width: 18, height: 18,
            child: CircularProgressIndicator(
                color: Colors.white, strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text('Invoice save ஆகிறது...'),
        ]),
        duration: Duration(seconds: 30),
        backgroundColor: Color(0xFF1565C0),
      ),
    );

    try {
      final invoiceProvider = context.read<InvoiceProvider>();
      final invoice = await invoiceProvider.createInvoice(
        customerId:     _selectedCustomer!.id,
        cartItems:      cart.items.toList(),
        taxPercent:     cart.taxPercent,
        discountAmount: cart.discountAmount,
        notes:          _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (invoice != null && context.mounted) {
        cart.clearCart();
        // Invoice detail screen-க்கு navigate
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => InvoiceDetailScreen(invoice: invoice),
          ),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                invoiceProvider.error ?? 'Invoice create ஆகவில்லை!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('Cart & Checkout',
            style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, _) {
          if (cart.items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 72, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Cart காலியாக உள்ளது',
                      style: TextStyle(
                          fontSize: 16, color: Colors.grey)),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Customer Select ──
                _CustomerSelector(
                  customers: _customers,
                  selected: _selectedCustomer,
                  loading: _loadingCustomers,
                  onSelect: (c) => setState(() => _selectedCustomer = c),
                  onRefresh: _loadCustomers,
                  onAddNew: () => _showAddCustomer(context),
                ),
                const SizedBox(height: 14),

                // ── Cart Items ──
                _CartItemsCard(cart: cart),
                const SizedBox(height: 14),

                // ── Bill Summary ──
                _BillSummaryCard(cart: cart),
                const SizedBox(height: 14),

                // ── Notes ──
                _NotesField(controller: _notesController),
                const SizedBox(height: 20),

                // ── Create Invoice Button ──
                Consumer<InvoiceProvider>(
                  builder: (_, inv, __) => SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: inv.isLoading ? null : _createInvoice,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedCustomer != null
                            ? const Color(0xFF1565C0)
                            : Colors.grey,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: inv.isLoading
                          ? const SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.receipt_long,
                              color: Colors.white),
                      label: Text(
                        inv.isLoading
                            ? 'Invoice save ஆகிறது...'
                            : 'Invoice உருவாக்கு  •  ₹${cart.grandTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Add New Customer Dialog ──
  void _showAddCustomer(BuildContext context) {
    final nameCtrl  = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('புதிய Customer',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'பெயர் *',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone *',
                prefixIcon: Icon(Icons.phone_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email (optional)',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0)),
            onPressed: () async {
              if (nameCtrl.text.isEmpty || phoneCtrl.text.isEmpty) {
                return;
              }
              try {
                final data = await _api.post('/customers', {
                  'name':  nameCtrl.text.trim(),
                  'phone': phoneCtrl.text.trim(),
                  if (emailCtrl.text.isNotEmpty)
                    'email': emailCtrl.text.trim(),
                });
                final newCustomer = Customer.fromJson(data);
                setState(() {
                  _customers.add(newCustomer);
                  _selectedCustomer = newCustomer;
                });
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                // error
              }
            },
            child: const Text('Save',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}

// ============================================
// Customer Selector Widget
// ============================================
class _CustomerSelector extends StatelessWidget {
  final List<Customer> customers;
  final Customer? selected;
  final bool loading;
  final Function(Customer) onSelect;
  final VoidCallback onRefresh;
  final VoidCallback onAddNew;

  const _CustomerSelector({
    required this.customers,
    required this.selected,
    required this.loading,
    required this.onSelect,
    required this.onRefresh,
    required this.onAddNew,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected != null
              ? const Color(0xFF1565C0).withOpacity(0.4)
              : Colors.grey.shade200,
          width: selected != null ? 1.5 : 1,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_outline,
                  color: Color(0xFF1565C0), size: 18),
              const SizedBox(width: 6),
              const Text('Customer',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 14)),
              const Spacer(),
              // Refresh
              InkWell(
                onTap: onRefresh,
                child: const Icon(Icons.refresh,
                    size: 18, color: Colors.grey),
              ),
              const SizedBox(width: 8),
              // Add new
              InkWell(
                onTap: onAddNew,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add,
                          size: 14, color: Color(0xFF1565C0)),
                      SizedBox(width: 2),
                      Text('புதியது',
                          style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF1565C0),
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (loading)
            const Center(
                child: CircularProgressIndicator(
                    color: Color(0xFF1565C0)))
          else if (customers.isEmpty)
            GestureDetector(
              onTap: onAddNew,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: Colors.grey.shade200,
                      style: BorderStyle.solid),
                ),
                child: const Text(
                  '+ Customer சேர்க்கவும்',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Color(0xFF1565C0),
                      fontWeight: FontWeight.w500),
                ),
              ),
            )
          else
            DropdownButtonFormField<Customer>(
              value: selected,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
                hintText: 'Customer select செய்யுங்கள்',
              ),
              items: customers.map((c) => DropdownMenuItem(
                value: c,
                child: Text('${c.name} — ${c.phone}',
                    style: const TextStyle(fontSize: 13)),
              )).toList(),
              onChanged: (c) { if (c != null) onSelect(c); },
            ),
        ],
      ),
    );
  }
}

// ============================================
// Cart Items Card
// ============================================
class _CartItemsCard extends StatelessWidget {
  final CartProvider cart;
  const _CartItemsCard({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(13)),
            ),
            child: Row(
              children: [
                const Icon(Icons.shopping_cart_outlined,
                    color: Color(0xFF1565C0), size: 16),
                const SizedBox(width: 6),
                Text('${cart.itemCount} Products  •  ${cart.totalQty} Items',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Color(0xFF1565C0))),
              ],
            ),
          ),
          // Items
          ...cart.items.map((item) => _CartItemRow(item: item)).toList(),
        ],
      ),
    );
  }
}

class _CartItemRow extends StatelessWidget {
  final CartItem item;
  const _CartItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(
        border: Border(
            top: BorderSide(color: Colors.grey.shade100, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(item.product.name,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500)),
          ),
          Text('${item.qty} × ₹${item.product.price.toStringAsFixed(2)}',
              style: TextStyle(
                  fontSize: 12, color: Colors.grey.shade500)),
          const SizedBox(width: 12),
          Text('₹${item.lineTotal.toStringAsFixed(2)}',
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1565C0))),
        ],
      ),
    );
  }
}

// ============================================
// Bill Summary Card
// ============================================
class _BillSummaryCard extends StatelessWidget {
  final CartProvider cart;
  const _BillSummaryCard({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _Row('Subtotal', '₹${cart.subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          // Tax selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                const Text('GST ',
                    style: TextStyle(
                        fontSize: 13, color: Colors.grey)),
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(6)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [0.0, 5.0, 12.0, 18.0].map((t) =>
                      GestureDetector(
                        onTap: () =>
                            context.read<CartProvider>().setTax(t),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: cart.taxPercent == t
                                ? const Color(0xFF1565C0)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text('${t.toInt()}%',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: cart.taxPercent == t
                                      ? Colors.white
                                      : Colors.grey)),
                        ),
                      ),
                    ).toList(),
                  ),
                ),
              ]),
              Text('+₹${cart.taxAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                      fontSize: 13)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Grand Total',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800)),
              Text('₹${cart.grandTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1565C0))),
            ],
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String l, v;
  const _Row(this.l, this.v);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(l,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
        Text(v,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

// ============================================
// Notes Field
// ============================================
class _NotesField extends StatelessWidget {
  final TextEditingController controller;
  const _NotesField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      padding: const EdgeInsets.all(14),
      child: TextField(
        controller: controller,
        maxLines: 2,
        decoration: InputDecoration(
          hintText: 'Notes (optional) — குறிப்புகள்...',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.note_outlined,
              color: Colors.grey, size: 18),
        ),
      ),
    );
  }
}