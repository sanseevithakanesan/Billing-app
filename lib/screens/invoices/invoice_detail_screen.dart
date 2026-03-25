import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/invoice.dart';
import '../../widgets/share_invoice_button.dart';
import '../../services/pdf_service.dart';
import '../../services/api_service.dart';

class InvoiceDetailScreen extends StatefulWidget {
  final Invoice invoice;
  const InvoiceDetailScreen({super.key, required this.invoice});

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  late Invoice _invoice;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _invoice = widget.invoice;
  }

  Color get _statusColor {
    switch (_invoice.status) {
      case 'paid':
        return Colors.green;
      case 'unpaid':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String get _statusLabel {
    switch (_invoice.status) {
      case 'paid':
        return 'PAID';
      case 'unpaid':
        return 'UNPAID';
      case 'cancelled':
        return 'CANCELLED';
      default:
        return _invoice.status.toUpperCase();
    }
  }

  Future<void> _refreshInvoice() async {
    setState(() => _isLoading = true);
    try {
      final api = ApiService();
      final data = await api.get('/invoices/${_invoice.id}');
      setState(() {
        _invoice = Invoice.fromJson(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh invoice: $e'),
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
        title: Text(_invoice.invoiceNo,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_outlined),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _invoice.invoiceNo));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Invoice number copied!'),
                    duration: Duration(seconds: 1)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () => _shareInvoice(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF1565C0),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _InvoiceHeaderCard(
                      invoice: _invoice,
                      statusColor: _statusColor,
                      statusLabel: _statusLabel),
                  const SizedBox(height: 12),

                  // ── Customer Card ──
                  if (_invoice.customer != null)
                    _CustomerCard(customer: _invoice.customer!),
                  const SizedBox(height: 12),

                  // ── Customer Invoices ──
                  if (_invoice.customer != null)
                    _CustomerInvoicesCard(
                      customerId: _invoice.customer!.id,
                      currentInvoiceId: _invoice.id,
                    ),
                  const SizedBox(height: 12),

                  // ── Customer Select Dropdown ──
                  _CustomerSelectDropdown(
                    currentCustomerId: _invoice.customer?.id,
                    currentInvoiceId: _invoice.id,
                    onCustomerUpdated: _refreshInvoice,
                  ),
                  const SizedBox(height: 12),

                  _ItemsTable(items: _invoice.items),
                  const SizedBox(height: 12),

                  _BillSummaryCard(invoice: _invoice),
                  const SizedBox(height: 12),

                  if (_invoice.notes != null && _invoice.notes!.isNotEmpty)
                    _NotesCard(notes: _invoice.notes!),

                  const SizedBox(height: 24),

                  ShareInvoiceButton(invoice: _invoice),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  void _shareInvoice(BuildContext context) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(children: [
            SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2)),
            SizedBox(width: 10),
            Text('PDF creating...'),
          ]),
          duration: Duration(seconds: 30),
          backgroundColor: Color(0xFF1565C0),
        ),
      );
      await PdfService.generateAndShare(_invoice);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }
}

// ============================================
// Customer Select Dropdown (CORRECTED VERSION)
// ============================================
class _CustomerSelectDropdown extends StatefulWidget {
  final int? currentCustomerId;
  final int currentInvoiceId;
  final VoidCallback onCustomerUpdated;

  const _CustomerSelectDropdown({
    required this.currentCustomerId,
    required this.currentInvoiceId,
    required this.onCustomerUpdated,
  });

  @override
  State<_CustomerSelectDropdown> createState() =>
      _CustomerSelectDropdownState();
}

class _CustomerSelectDropdownState extends State<_CustomerSelectDropdown> {
  final _api = ApiService();
  List<Map<String, dynamic>> _customers = [];
  bool _loading = true;
  int? _selectedCustomerId;
  bool _updating = false;

  @override
  void initState() {
    super.initState();
    _selectedCustomerId = widget.currentCustomerId;
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    try {
      final data = await _api.get('/customers');
      setState(() {
        if (data is List) {
          _customers = List<Map<String, dynamic>>.from(data);
        } else if (data['data'] is List) {
          _customers = List<Map<String, dynamic>>.from(data['data']);
        } else if (data['customers'] is List) {
          _customers = List<Map<String, dynamic>>.from(data['customers']);
        } else {
          _customers = [];
        }
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load customers: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateInvoiceCustomer() async {
    if (_selectedCustomerId == widget.currentCustomerId) return;

    setState(() => _updating = true);

    try {
      Map<String, dynamic> requestBody = {
        'customer_id': _selectedCustomerId,
      };

      print('Updating invoice ${widget.currentInvoiceId} with: $requestBody');
      
      // Use PUT method (Laravel apiResource supports PUT/PATCH)
      final response = await _api.put(
        '/invoices/${widget.currentInvoiceId}',
        requestBody,
      );
      
      print('Update response: $response');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Customer updated successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Call the refresh callback
        widget.onCustomerUpdated();
      }
    } catch (e) {
      print('Update error: $e');
      if (mounted) {
        String errorMessage = 'Failed to update customer';
        String errorDetails = e.toString();
        
        if (errorDetails.contains('422')) {
          errorMessage = 'Validation error. Customer ID may be invalid.';
        } else if (errorDetails.contains('404')) {
          errorMessage = 'Invoice not found.';
        } else if (errorDetails.contains('500')) {
          errorMessage = 'Server error. Please try again.';
        } else if (errorDetails.contains('401')) {
          errorMessage = 'Unauthorized. Please login again.';
        } else if (errorDetails.contains('403')) {
          errorMessage = 'Permission denied.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$errorMessage\n${errorDetails.length > 100 ? errorDetails.substring(0, 100) : errorDetails}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _updating = false);
      }
    }
  }

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.people_outline,
                    color: Color(0xFF1565C0), size: 16),
              ),
              const SizedBox(width: 10),
              const Text(
                'Change Customer',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              if (_updating)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF1565C0),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(
                  color: Color(0xFF1565C0),
                ),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int?>(
                  value: _selectedCustomerId,
                  hint: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('Select a customer'),
                  ),
                  isExpanded: true,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('No Customer'),
                    ),
                    ..._customers.map((customer) {
                      return DropdownMenuItem<int?>(
                        value: customer['id'],
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              customer['name'] ?? 'Unknown',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            if (customer['phone'] != null)
                              Text(
                                customer['phone'],
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                  onChanged: _updating
                      ? null
                      : (value) {
                          setState(() {
                            _selectedCustomerId = value;
                          });
                        },
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1565C0),
                    fontWeight: FontWeight.w500,
                  ),
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: Colors.grey.shade400,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          const SizedBox(height: 12),
          if (!_loading && _selectedCustomerId != widget.currentCustomerId)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _updating ? null : _updateInvoiceCustomer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  _updating ? 'Updating...' : 'Update Customer',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================
// Customer Invoices Card
// ============================================
class _CustomerInvoicesCard extends StatefulWidget {
  final int customerId;
  final int currentInvoiceId;

  const _CustomerInvoicesCard({
    required this.customerId,
    required this.currentInvoiceId,
  });

  @override
  State<_CustomerInvoicesCard> createState() => _CustomerInvoicesCardState();
}

class _CustomerInvoicesCardState extends State<_CustomerInvoicesCard> {
  final _api = ApiService();
  List<dynamic> _invoices = [];
  bool _loading = true;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await _api.get('/customers/${widget.customerId}/invoices');
      setState(() {
        final list = data['invoices'] ?? data ?? [];
        _invoices = (list as List)
            .where((inv) => inv['id'] != widget.currentInvoiceId)
            .toList();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

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
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.receipt_long_outlined,
                        color: Color(0xFF1565C0), size: 16),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Customer Invoices',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const Spacer(),
                  if (_loading)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Color(0xFF1565C0)),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_invoices.length} invoices',
                        style: const TextStyle(
                            color: Color(0xFF1565C0),
                            fontWeight: FontWeight.w600,
                            fontSize: 11),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            Divider(height: 1, color: Colors.grey.shade100),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(color: Color(0xFF1565C0)),
              )
            else if (_invoices.isEmpty)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.receipt_outlined,
                        size: 36, color: Colors.grey.shade300),
                    const SizedBox(height: 8),
                    Text(
                      'No other invoices',
                      style:
                          TextStyle(color: Colors.grey.shade400, fontSize: 13),
                    ),
                  ],
                ),
              )
            else
              ..._invoices.map((inv) => InkWell(
                    onTap: () {
                      final invoice = Invoice.fromJson(inv);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => InvoiceDetailScreen(invoice: invoice),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                            top: BorderSide(
                                color: Colors.grey.shade100, width: 0.5)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F7FA),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.receipt_outlined,
                                color: Color(0xFF1565C0), size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  inv['invoice_no'] ?? '',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  inv['created_at']
                                          ?.toString()
                                          .substring(0, 10) ??
                                      '',
                                  style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '₹${double.parse(inv['total'].toString()).toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1565C0),
                                    fontSize: 13),
                              ),
                              const SizedBox(height: 3),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: inv['status'] == 'paid'
                                      ? Colors.green.shade50
                                      : Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  (inv['status'] ?? '')
                                      .toString()
                                      .toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: inv['status'] == 'paid'
                                        ? Colors.green.shade700
                                        : Colors.orange.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.chevron_right,
                              color: Colors.grey.shade300, size: 18),
                        ],
                      ),
                    ),
                  )).toList(),
          ],
        ],
      ),
    );
  }
}

// ============================================
// Invoice Header Card
// ============================================
class _InvoiceHeaderCard extends StatelessWidget {
  final Invoice invoice;
  final Color statusColor;
  final String statusLabel;

  const _InvoiceHeaderCard({
    required this.invoice,
    required this.statusColor,
    required this.statusLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.receipt_long,
                    color: Colors.white, size: 24),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      letterSpacing: 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(invoice.invoiceNo,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text('Date: ${invoice.createdAt.substring(0, 10)}',
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Grand Total',
                      style: TextStyle(color: Colors.white60, fontSize: 12)),
                  Text('₹${invoice.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Items',
                      style: TextStyle(color: Colors.white60, fontSize: 12)),
                  Text('${invoice.items.length}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================
// Customer Card
// ============================================
class _CustomerCard extends StatelessWidget {
  final customer;
  const _CustomerCard({required this.customer});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              color: Color(0xFFE3F2FD),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                customer.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1565C0)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(customer.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15)),
                Text(customer.phone,
                    style:
                        TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                if (customer.email != null)
                  Text(customer.email!,
                      style:
                          TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.person_outline, color: Color(0xFF1565C0), size: 20),
        ],
      ),
    );
  }
}

// ============================================
// Items Table
// ============================================
class _ItemsTable extends StatelessWidget {
  final List items;
  const _ItemsTable({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF5F7FA),
              borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text('Product',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: Color(0xFF1565C0))),
                ),
                SizedBox(
                  width: 40,
                  child: Text('Qty',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: Color(0xFF1565C0))),
                ),
                SizedBox(
                  width: 70,
                  child: Text('Rate',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: Color(0xFF1565C0))),
                ),
                SizedBox(
                  width: 80,
                  child: Text('Total',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: Color(0xFF1565C0))),
                ),
              ],
            ),
          ),
          ...items.asMap().entries.map((e) {
            final i = e.key;
            final item = e.value;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: i.isEven ? Colors.white : const Color(0xFFFAFBFC),
                border: Border(
                    top: BorderSide(color: Colors.grey.shade100, width: 0.5)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(item.productName,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ),
                  SizedBox(
                    width: 40,
                    child: Text('${item.qty}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                  SizedBox(
                    width: 70,
                    child: Text('₹${item.unitPrice.toStringAsFixed(0)}',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600)),
                  ),
                  SizedBox(
                    width: 80,
                    child: Text('₹${item.lineTotal.toStringAsFixed(2)}',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1565C0))),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

// ============================================
// Bill Summary Card
// ============================================
class _BillSummaryCard extends StatelessWidget {
  final Invoice invoice;
  const _BillSummaryCard({required this.invoice});

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
          _SummaryRow('Subtotal', '₹${invoice.subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _SummaryRow('GST (${invoice.taxPercent.toInt()}%)',
              '+₹${invoice.taxAmount.toStringAsFixed(2)}',
              valueColor: Colors.orange),
          if (invoice.discountAmount > 0) ...[
            const SizedBox(height: 8),
            _SummaryRow(
                'Discount', '-₹${invoice.discountAmount.toStringAsFixed(2)}',
                valueColor: Colors.green),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Grand Total',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              Text('₹${invoice.total.toStringAsFixed(2)}',
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

class _SummaryRow extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  const _SummaryRow(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
        Text(value,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? Colors.grey.shade800)),
      ],
    );
  }
}

// ============================================
// Notes Card
// ============================================
class _NotesCard extends StatelessWidget {
  final String notes;
  const _NotesCard({required this.notes});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDE7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFF176)),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.note_outlined, color: Color(0xFFF9A825), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(notes,
                style: const TextStyle(fontSize: 13, color: Color(0xFF795548))),
          ),
        ],
      ),
    );
  }
}