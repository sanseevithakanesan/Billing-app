// lib/services/share_service.dart
import 'package:share_plus/share_plus.dart';
import '../models/invoice.dart';

class ShareService {
  static const String storeName = 'My Billing Store';
  static const String storePhone = '+91 98765 43210';

  // ── Clean WhatsApp message ─────────────────
  static String buildWhatsAppMessage(Invoice invoice) {
    final sb = StringBuffer();

    sb.writeln('🧾 *INVOICE*');
    sb.writeln();
    sb.writeln('*$storeName*');
    sb.writeln('📞 $storePhone');
    sb.writeln();

    sb.writeln('*Invoice No:* ${invoice.invoiceNo}');
    sb.writeln('*Date:* ${invoice.createdAt.substring(0, 10)}');

    if (invoice.customer != null) {
      sb.writeln('*Customer:* ${invoice.customer!.name}');
      sb.writeln('*Phone:* ${invoice.customer!.phone}');
    }

    sb.writeln();
    sb.writeln('*Items:*');
    sb.writeln('```');
    for (final item in invoice.items) {
      sb.writeln('${item.productName}');
      sb.writeln(
          '  ${item.qty} x ₹${item.unitPrice.toStringAsFixed(2)} = ₹${item.lineTotal.toStringAsFixed(2)}');
    }
    sb.writeln('```');

    sb.writeln('*Subtotal:* ₹${invoice.subtotal.toStringAsFixed(2)}');
    sb.writeln(
        '*GST (${invoice.taxPercent.toInt()}%):* ₹${invoice.taxAmount.toStringAsFixed(2)}');
    if (invoice.discountAmount > 0) {
      sb.writeln('*Discount:* -₹${invoice.discountAmount.toStringAsFixed(2)}');
    }
    sb.writeln();
    sb.writeln('💵 *TOTAL: ₹${invoice.total.toStringAsFixed(2)}*');
    sb.writeln();
    sb.writeln(invoice.status == 'paid' ? '✅ *PAID*' : '⏳ *Payment Pending*');
    sb.writeln();
    sb.writeln('_Thank you for shopping! 🙏_');

    return sb.toString();
  }

  static Future<void> shareInvoiceViaWhatsApp(Invoice invoice) async {
    final message = buildWhatsAppMessage(invoice);
    await Share.share(message);
    //await Share.share(message, subject: 'Invoice ${invoice.invoiceNo}');
  }
}
