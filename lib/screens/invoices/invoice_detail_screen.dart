
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/invoice.dart';
import '../../widgets/share_invoice_button.dart';
import '../../services/pdf_service.dart';

class InvoiceDetailScreen extends StatelessWidget {
  final Invoice invoice;
  const InvoiceDetailScreen({super.key, required this.invoice});

  // Status color
  Color get _statusColor {
    switch (invoice.status) {
      case 'paid':      return Colors.green;
      case 'unpaid':    return Colors.orange;
      case 'cancelled': return Colors.red;
      default:          return Colors.grey;
    }
  }

  String get _statusLabel {
    switch (invoice.status) {
      case 'paid':      return 'PAID';
      case 'unpaid':    return 'UNPAID';
      case 'cancelled': return 'CANCELLED';
      default:          return invoice.status.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: Text(invoice.invoiceNo,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 16)),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_outlined),
            onPressed: () {
              Clipboard.setData(
                  ClipboardData(text: invoice.invoiceNo));
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── Invoice Header Card ──
            _InvoiceHeaderCard(
                invoice: invoice,
                statusColor: _statusColor,
                statusLabel: _statusLabel),
            const SizedBox(height: 12),

            // ── Customer Card ──
            if (invoice.customer != null)
              _CustomerCard(customer: invoice.customer!),
            const SizedBox(height: 12),

            // ── Items Table ──
            _ItemsTable(items: invoice.items),
            const SizedBox(height: 12),

            // ── Bill Summary ──
            _BillSummaryCard(invoice: invoice),
            const SizedBox(height: 12),

            // ── Notes ──
            if (invoice.notes != null && invoice.notes!.isNotEmpty)
              _NotesCard(notes: invoice.notes!),

            const SizedBox(height: 24),

            // ── Print Button ──
          
            ShareInvoiceButton(invoice: invoice),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _shareInvoice(BuildContext context) async{
      try {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(children: [
          SizedBox(width:18, height:18,
            child: CircularProgressIndicator(color:Colors.white, strokeWidth:2)),
          SizedBox(width:10),
          Text('PDF creating...'),
        ]),
        duration: Duration(seconds: 30),
        backgroundColor: Color(0xFF1565C0),
      ),
    );
    await PdfService.generateAndShare(invoice);
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
              // Invoice icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.receipt_long,
                    color: Colors.white, size: 24),
              ),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 6),
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
          Text(
            invoice.invoiceNo,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5),
          ),
          const SizedBox(height: 4),
          Text(
            'Date: ${invoice.createdAt.substring(0, 10)}',
            style: const TextStyle(
                color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Grand Total',
                      style: TextStyle(
                          color: Colors.white60, fontSize: 12)),
                  Text(
                    '₹${invoice.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Items',
                      style: TextStyle(
                          color: Colors.white60, fontSize: 12)),
                  Text(
                    '${invoice.items.length}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800),
                  ),
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
                    style: TextStyle(
                        color: Colors.grey.shade500, fontSize: 13)),
                if (customer.email != null)
                  Text(customer.email!,
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.person_outline,
              color: Color(0xFF1565C0), size: 20),
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
          // Header
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF5F7FA),
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(13)),
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

          // Items
          ...items.asMap().entries.map((e) {
            final i = e.key;
            final item = e.value;
            return Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: i.isEven
                    ? Colors.white
                    : const Color(0xFFFAFBFC),
                border: Border(
                    top: BorderSide(
                        color: Colors.grey.shade100, width: 0.5)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      item.productName,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(
                    width: 40,
                    child: Text(
                      '${item.qty}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                  SizedBox(
                    width: 70,
                    child: Text(
                      '₹${item.unitPrice.toStringAsFixed(0)}',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600),
                    ),
                  ),
                  SizedBox(
                    width: 80,
                    child: Text(
                      '₹${item.lineTotal.toStringAsFixed(2)}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1565C0)),
                    ),
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
          _SummaryRow(
            'Subtotal',
            '₹${invoice.subtotal.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            'GST (${invoice.taxPercent.toInt()}%)',
            '+₹${invoice.taxAmount.toStringAsFixed(2)}',
            valueColor: Colors.orange,
          ),
          if (invoice.discountAmount > 0) ...[
            const SizedBox(height: 8),
            _SummaryRow(
              'Discount',
              '-₹${invoice.discountAmount.toStringAsFixed(2)}',
              valueColor: Colors.green,
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Grand Total',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w800),
              ),
              Text(
                '₹${invoice.total.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1565C0)),
              ),
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
            style: TextStyle(
                fontSize: 13, color: Colors.grey.shade600)),
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
          const Icon(Icons.note_outlined,
              color: Color(0xFFF9A825), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(notes,
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF795548))),
          ),
        ],
      ),
    );
  }
}

// ============================================
// Print Button
// ============================================
class _PrintButton extends StatelessWidget {
  final Invoice invoice;
  const _PrintButton({required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Print (thermal receipt format)
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () => _showPrintPreview(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            icon:
                const Icon(Icons.print_outlined, color: Colors.white),
            label: const Text(
              'Print Invoice',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Share as text
        SizedBox(
          width: double.infinity,
          height: 46,
          child: OutlinedButton.icon(
            onPressed: () {
              final text = _buildShareText();
              Clipboard.setData(ClipboardData(text: text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text(
                        'Invoice copied! Paste it in WhatsApp'),
                    backgroundColor: Colors.green),
              );
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF1565C0)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            //icon: const Icon(Icons.chat_outlined, color: Color(0xFF25D366)),
            label: const Text(
              'Share via WhatsApp',
              style: TextStyle(
                  color: Color(0xFF1565C0),
                  fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  String _buildShareText() {
    final sb = StringBuffer();
    sb.writeln('━━━━━━━━━━━━━━━━━━━━━━━━');
    sb.writeln('       INVOICE');
    sb.writeln('━━━━━━━━━━━━━━━━━━━━━━━━');
    sb.writeln('No: ${invoice.invoiceNo}');
    sb.writeln('Date: ${invoice.createdAt.substring(0, 10)}');
    if (invoice.customer != null) {
      sb.writeln('Customer: ${invoice.customer!.name}');
      sb.writeln('Phone: ${invoice.customer!.phone}');
    }
    sb.writeln('─────────────────────────');
    for (final item in invoice.items) {
      sb.writeln('${item.productName}');
      sb.writeln(
          '  ${item.qty} x ₹${item.unitPrice.toStringAsFixed(2)} = ₹${item.lineTotal.toStringAsFixed(2)}');
    }
    sb.writeln('─────────────────────────');
    sb.writeln('Subtotal : ₹${invoice.subtotal.toStringAsFixed(2)}');
    sb.writeln(
        'GST(${invoice.taxPercent.toInt()}%)  : ₹${invoice.taxAmount.toStringAsFixed(2)}');
    if (invoice.discountAmount > 0) {
      sb.writeln(
          'Discount : -₹${invoice.discountAmount.toStringAsFixed(2)}');
    }
    sb.writeln('━━━━━━━━━━━━━━━━━━━━━━━━');
    sb.writeln(
        'TOTAL    : ₹${invoice.total.toStringAsFixed(2)}');
    sb.writeln('━━━━━━━━━━━━━━━━━━━━━━━━');
    sb.writeln('Thank you for shopping!');
    return sb.toString();
  }

  void _showPrintPreview(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Print Preview',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16)),
                    TextButton.icon(
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: _buildShareText()));
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Copied to clipboard!')),
                        );
                      },
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Copy'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: controller,
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _buildShareText(),
                      style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 13,
                          height: 1.8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}