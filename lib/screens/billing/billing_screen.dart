// lib/screens/billing/billing_screen.dart
// ── Scan மூலம் அல்லது Product List-லிருந்து real DB products add செய்யலாம் ──
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../models/cart_item.dart';
import '../products/product_list.dart';
import '../../providers/invoice_provider.dart';
import '../invoices/invoice_detail_screen.dart';
import '../billing/cart_screen.dart';
import '../auth/login_screen.dart';
import '../../providers/auth_provider.dart';


class BillingScreen extends StatelessWidget {
  const BillingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('Billing',
            style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Product List icon
          IconButton(
            icon: const Icon(Icons.inventory_2_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProductListScreen()),
            ),
            tooltip: 'Products பார்க்கவும்',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
            tooltip: 'Logout',
          ),
          // Clear cart
          // AppBar actions-ல் சேர்க்கவும்:
          IconButton(
            icon: Stack(children: [
              const Icon(Icons.shopping_cart_outlined),
              Consumer<CartProvider>(
                builder: (_, cart, __) => cart.itemCount > 0
                    ? Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text('${cart.itemCount}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 9)),
                        ),
                      )
                    : const SizedBox(),
              ),
            ]),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            ),
          ),
          Consumer<CartProvider>(
            builder: (_, cart, __) => cart.itemCount > 0
                ? IconButton(
                    icon: const Icon(Icons.delete_sweep_outlined),
                    onPressed: () => _confirmClear(context),
                  )
                : const SizedBox(),
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, _) {
          if (cart.items.isEmpty) {
            return const _EmptyCartView();
          }
          return Column(
            children: [
              _CartHeader(cart: cart),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  itemCount: cart.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) => _CartItemCard(item: cart.items[i]),
                ),
              ),
              _BillSummary(cart: cart),
            ],
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Product List Button
          FloatingActionButton(
            heroTag: 'list',
            mini: true,
            backgroundColor: Colors.white,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProductListScreen()),
            ),
            child: const Icon(Icons.list, color: Color(0xFF1565C0)),
          ),
          const SizedBox(height: 8),
          // Scan Button
          FloatingActionButton.extended(
            heroTag: 'scan',
            onPressed: () => _startScan(context),
            backgroundColor: const Color(0xFF1565C0),
            icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
            label: const Text('Scan',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // ── Barcode Scan → API → Cart ──
  Future<void> _startScan(BuildContext context) async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const _ScannerPage()),
    );

    if (result != null && result.isNotEmpty && context.mounted) {
      final provider = context.read<ProductProvider>();
      final cart = context.read<CartProvider>();

      // Loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(children: [
            SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2)),
            SizedBox(width: 12),
            Text('Product தேடுகிறோம்...'),
          ]),
          duration: Duration(seconds: 10),
          backgroundColor: Color(0xFF1565C0),
        ),
      );

      final product = await provider.findByBarcode(result);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (product != null) {
        cart.addProduct(product);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.name} சேர்க்கப்பட்டது!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product கிடைக்கவில்லை!\nBarcode: $result'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cart Clear செய்யவா?'),
        content: const Text('அனைத்து products-ம் நீக்கப்படும்.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<CartProvider>().clearCart();
              Navigator.pop(context);
            },
            child: const Text('Clear', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ============================================
// Barcode Scanner Page
// ============================================
class _ScannerPage extends StatefulWidget {
  const _ScannerPage();

  @override
  State<_ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<_ScannerPage> {
  final MobileScannerController _controller = MobileScannerController();
  bool _scanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Barcode Scan'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera preview
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              if (_scanned) return;
              final barcode = capture.barcodes.firstOrNull;
              if (barcode?.rawValue != null) {
                _scanned = true;
                Navigator.pop(context, barcode!.rawValue);
              }
            },
          ),

          // Overlay
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5),
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(
                    decoration: const BoxDecoration(
                        color: Colors.black,
                        backgroundBlendMode: BlendMode.dstOut)),
                Center(
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Scan box border
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          // Bottom text
          const Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Text(
              'Barcode-ஐ box-க்குள் வையுங்கள்',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// ============================================
// Cart Header
// ============================================
class _CartHeader extends StatelessWidget {
  final CartProvider cart;
  const _CartHeader({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1565C0),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Row(
        children: [
          _Badge('${cart.itemCount}', 'Products'),
          const SizedBox(width: 10),
          _Badge('${cart.totalQty}', 'Total Qty'),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Grand Total',
                  style: TextStyle(color: Colors.white70, fontSize: 11)),
              Text('₹${cart.grandTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String value, label;
  const _Badge(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16)),
          Text(label,
              style: const TextStyle(color: Colors.white60, fontSize: 10)),
        ],
      ),
    );
  }
}

// ============================================
// Cart Item Card
// ============================================
class _CartItemCard extends StatelessWidget {
  final CartItem item;
  const _CartItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                item.product.name.substring(0, 1),
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1565C0)),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Name + price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text('₹${item.product.price.toStringAsFixed(2)} × ${item.qty}',
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
          ),

          // Qty control
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () => cart.decreaseQty(item.product.id),
                  child: Padding(
                    padding: const EdgeInsets.all(7),
                    child: Icon(
                        item.qty == 1 ? Icons.delete_outline : Icons.remove,
                        size: 16,
                        color: item.qty == 1
                            ? Colors.red
                            : const Color(0xFF1565C0)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text('${item.qty}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
                ),
                InkWell(
                  onTap: () => cart.increaseQty(item.product.id),
                  child: const Padding(
                    padding: EdgeInsets.all(7),
                    child: Icon(Icons.add, size: 16, color: Color(0xFF1565C0)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Line total
          SizedBox(
            width: 72,
            child: Text('₹${item.lineTotal.toStringAsFixed(2)}',
                textAlign: TextAlign.right,
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Color(0xFF1565C0))),
          ),
        ],
      ),
    );
  }
}

// ============================================
// Bill Summary
// ============================================
class _BillSummary extends StatefulWidget {
  final CartProvider cart;
  const _BillSummary({required this.cart});

  @override
  State<_BillSummary> createState() => _BillSummaryState();
}

class _BillSummaryState extends State<_BillSummary> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final cart = widget.cart;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -4))
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 4),
                  Text(_expanded ? 'மூடு' : 'Bill summary பார்க்கவும்',
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Column(
                children: [
                  _Row('Subtotal (${cart.totalQty} items)',
                      '₹${cart.subtotal.toStringAsFixed(2)}'),
                  // Tax selector
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          const Text('GST ',
                              style:
                                  TextStyle(fontSize: 13, color: Colors.grey)),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(6)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [0.0, 5.0, 12.0, 18.0]
                                  .map((t) => GestureDetector(
                                        onTap: () => context
                                            .read<CartProvider>()
                                            .setTax(t),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: cart.taxPercent == t
                                                ? const Color(0xFF1565C0)
                                                : Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: Text('${t.toInt()}%',
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: cart.taxPercent == t
                                                      ? Colors.white
                                                      : Colors.grey)),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                        ]),
                        Text('+₹${cart.taxAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  const Divider(height: 8),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Grand Total',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    Text('₹${cart.grandTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1565C0))),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () => _showConfirm(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.receipt_long, color: Colors.white),
                    label: Text('Bill உருவாக்கு  •  ${cart.itemCount} items',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirm(BuildContext context) {
    final cart = context.read<CartProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 48),
            const SizedBox(height: 12),
            const Text('Bill Confirm',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            _Row('Subtotal', '₹${cart.subtotal.toStringAsFixed(2)}'),
            _Row('GST (${cart.taxPercent.toInt()}%)',
                '+₹${cart.taxAmount.toStringAsFixed(2)}'),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Grand Total',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                Text('₹${cart.grandTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        color: Color(0xFF1565C0))),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    // onPressed: () {
                    //   Navigator.pop(context);
                    //   cart.clearCart();
                    //   ScaffoldMessenger.of(context).showSnackBar(
                    //     const SnackBar(
                    //         content: Text('Bill saved!'),
                    //         backgroundColor: Colors.green),
                    //   );
                    // },
                    // billing_screen.dart-ல் _showConfirm method-ல் இதை paste செய்யுங்கள்:
                    onPressed: () async {
                      Navigator.pop(context);

                      // Loading show
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Row(children: [
                            SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2)),
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
                          customerId: 1,
                          cartItems: cart.items.toList(),
                          taxPercent: cart.taxPercent,
                          discountAmount: cart.discountAmount,
                        );

                        ScaffoldMessenger.of(context).hideCurrentSnackBar();

                        if (invoice != null && context.mounted) {
                          cart.clearCart();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  InvoiceDetailScreen(invoice: invoice),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(invoiceProvider.error ??
                                  'Invoice create ஆகவில்லை!'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Confirm & Save',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String l, v;
  const _Row(this.l, this.v);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(l, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          Text(v,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ============================================
// Empty Cart View
// ============================================
class _EmptyCartView extends StatelessWidget {
  const _EmptyCartView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined,
              size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('Cart காலியாக உள்ளது',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500)),
          const SizedBox(height: 8),
          Text('Scan அல்லது Product List-லிருந்து சேர்க்கவும்',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade400)),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
