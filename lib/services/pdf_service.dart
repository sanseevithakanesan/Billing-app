// lib/services/pdf_service.dart
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/invoice.dart';

class PdfService {
  static const String storeName  = 'My Billing Store';
  static const String storePhone = '+91 98765 43210';
  static const String storeEmail = 'store@billing.com';


  static Future<void> generateAndShare(Invoice invoice) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [

              // ── Header ──────────────────────
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#1565C0'),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          storeName,
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(storePhone,
                            style: const pw.TextStyle(
                                color: PdfColors.white, fontSize: 11)),
                        pw.Text(storeEmail,
                            style: const pw.TextStyle(
                                color: PdfColors.white, fontSize: 11)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'INVOICE',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          invoice.invoiceNo,
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 13,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          'Date: ${invoice.createdAt.substring(0, 10)}',
                          style: const pw.TextStyle(
                              color: PdfColors.white, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // ── Customer + Status ───────────
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Customer info
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(14),
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('#F5F7FA'),
                        borderRadius: pw.BorderRadius.circular(6),
                        border: pw.Border.all(
                            color: PdfColor.fromHex('#E0E0E0'), width: 0.5),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Bill To:',
                              style: pw.TextStyle(
                                  fontSize: 10,
                                  color: PdfColor.fromHex('#666666'))),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            invoice.customer?.name ?? 'Walk-in Customer',
                            style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold),
                          ),
                          if (invoice.customer?.phone != null)
                            pw.Text(invoice.customer!.phone,
                                style: const pw.TextStyle(fontSize: 11)),
                          if (invoice.customer?.email != null)
                            pw.Text(invoice.customer!.email!,
                                style: const pw.TextStyle(fontSize: 11)),
                          if (invoice.customer?.address != null)
                            pw.Text(invoice.customer!.address!,
                                style: const pw.TextStyle(
                                    fontSize: 10,
                                    color: PdfColors.grey)),
                        ],
                      ),
                    ),
                  ),

                  pw.SizedBox(width: 16),

                  // Status
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: pw.BoxDecoration(
                      color: invoice.status == 'paid'
                          ? PdfColor.fromHex('#E8F5E9')
                          : PdfColor.fromHex('#FFF3E0'),
                      borderRadius: pw.BorderRadius.circular(20),
                      border: pw.Border.all(
                        color: invoice.status == 'paid'
                            ? PdfColor.fromHex('#4CAF50')
                            : PdfColor.fromHex('#FF9800'),
                        width: 1,
                      ),
                    ),
                    child: pw.Text(
                      invoice.status.toUpperCase(),
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: invoice.status == 'paid'
                            ? PdfColor.fromHex('#2E7D32')
                            : PdfColor.fromHex('#E65100'),
                      ),
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 20),

              // ── Items Table ─────────────────
              pw.Text('Items',
                  style: pw.TextStyle(
                      fontSize: 13,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('#1565C0'))),
              pw.SizedBox(height: 8),

              pw.Table(
                border: pw.TableBorder(
                  bottom: pw.BorderSide(
                      color: PdfColor.fromHex('#E0E0E0'), width: 0.5),
                  horizontalInside: pw.BorderSide(
                      color: PdfColor.fromHex('#F0F0F0'), width: 0.5),
                ),
                columnWidths: {
                  0: const pw.FlexColumnWidth(4),
                  1: const pw.FixedColumnWidth(50),
                  2: const pw.FixedColumnWidth(80),
                  3: const pw.FixedColumnWidth(90),
                },
                children: [
                  // Table header
                  pw.TableRow(
                    decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('#1565C0')),
                    children: [
                      _tableHeader('Product'),
                      _tableHeader('Qty', align: pw.TextAlign.center),
                      _tableHeader('Rate', align: pw.TextAlign.right),
                      _tableHeader('Total', align: pw.TextAlign.right),
                    ],
                  ),

                  // Items
                  ...invoice.items.asMap().entries.map((e) {
                    final isEven = e.key.isEven;
                    final item   = e.value;
                    return pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color: isEven
                            ? PdfColors.white
                            : PdfColor.fromHex('#FAFAFA'),
                      ),
                      children: [
                        _tableCell(item.productName),
                        _tableCell('${item.qty}',
                            align: pw.TextAlign.center),
                        _tableCell(
                            '₹${item.unitPrice.toStringAsFixed(2)}',
                            align: pw.TextAlign.right),
                        _tableCell(
                            '₹${item.lineTotal.toStringAsFixed(2)}',
                            align: pw.TextAlign.right,
                            bold: true),
                      ],
                    );
                  }).toList(),
                ],
              ),

              pw.SizedBox(height: 20),

              // ── Bill Summary ────────────────
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    width: 240,
                    padding: const pw.EdgeInsets.all(14),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#F5F7FA'),
                      borderRadius: pw.BorderRadius.circular(8),
                      border: pw.Border.all(
                          color: PdfColor.fromHex('#E0E0E0'), width: 0.5),
                    ),
                    child: pw.Column(
                      children: [
                        _summaryRow('Subtotal',
                            '₹${invoice.subtotal.toStringAsFixed(2)}'),
                        pw.SizedBox(height: 6),
                        _summaryRow(
                            'GST (${invoice.taxPercent.toInt()}%)',
                            '₹${invoice.taxAmount.toStringAsFixed(2)}'),
                        if (invoice.discountAmount > 0) ...[
                          pw.SizedBox(height: 6),
                          _summaryRow('Discount',
                              '-₹${invoice.discountAmount.toStringAsFixed(2)}'),
                        ],
                        pw.SizedBox(height: 8),
                        pw.Divider(
                            color: PdfColor.fromHex('#CCCCCC'),
                            height: 1),
                        pw.SizedBox(height: 8),
                        pw.Row(
                          mainAxisAlignment:
                              pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('GRAND TOTAL',
                                style: pw.TextStyle(
                                    fontSize: 13,
                                    fontWeight: pw.FontWeight.bold)),
                            pw.Text(
                              '₹${invoice.total.toStringAsFixed(2)}',
                              style: pw.TextStyle(
                                fontSize: 16,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColor.fromHex('#1565C0'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              if (invoice.notes != null &&
                  invoice.notes!.isNotEmpty) ...[
                pw.SizedBox(height: 16),
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#FFFDE7'),
                    borderRadius: pw.BorderRadius.circular(6),
                    border: pw.Border.all(
                        color: PdfColor.fromHex('#FFF176'), width: 0.5),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Notes:',
                          style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColor.fromHex('#795548'))),
                      pw.SizedBox(height: 4),
                      pw.Text(invoice.notes!,
                          style: pw.TextStyle(
                              fontSize: 11,
                              color: PdfColor.fromHex('#795548'))),
                    ],
                  ),
                ),
              ],

              pw.Spacer(),

              // ── Footer ──────────────────────
              pw.Divider(color: PdfColor.fromHex('#CCCCCC'), height: 1),
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text(
                  'Thank you for shopping! | $storeName | $storePhone',
                  style: const pw.TextStyle(
                      fontSize: 10, color: PdfColors.grey),
                ),
              ),
            ],
          );
        },
      ),
    );

    // ── PDF save & share ────────────────────
    final dir  = await getTemporaryDirectory();
    final file = File('${dir.path}/${invoice.invoiceNo}.pdf');
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/pdf')],
      subject: 'Invoice ${invoice.invoiceNo}',
      text: '${invoice.invoiceNo} - ₹${invoice.total.toStringAsFixed(2)}',
    );
  }

  // ── Table helpers ───────────────────────
  static pw.Widget _tableHeader(String text,
      {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          color: PdfColors.white,
          fontSize: 11,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  static pw.Widget _tableCell(String text,
      {pw.TextAlign align = pw.TextAlign.left, bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: 11,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  static pw.Widget _summaryRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label,
            style: const pw.TextStyle(
                fontSize: 11, color: PdfColors.grey)),
        pw.Text(value,
            style: const pw.TextStyle(fontSize: 11)),
      ],
    );
  }
}