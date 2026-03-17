import 'dart:io';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'model/customer.dart';
import 'model/invoice.dart';
import 'model/supplier.dart';

/// A generator class that creates professional PDF invoices from an [Invoice] model.
class PdfInvoiceGenerator {
  /// Generates a PDF invoice file from the provided [invoice] data.
  /// 
  /// The generated PDF is saved in the temporary directory with a filename
  /// based on the invoice number.
  /// 
  /// Returns a [File] object pointing to the generated PDF.
  static Future<File> generate(Invoice invoice) async {
    final pdf = pw.Document();

    pdf.addPage(pw.MultiPage(
      build: (context) => [
        _buildHeader(invoice),
        pw.SizedBox(height: 3 * PdfPageFormat.cm),
        _buildTitle(invoice),
        _buildInvoice(invoice),
        pw.Divider(),
        _buildTotal(invoice),
      ],
      footer: (context) => _buildFooter(invoice),
    ));

    final outputDir = await getTemporaryDirectory();
    final file = File(p.join(outputDir.path, 'invoice_${invoice.info.number}.pdf'));
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static pw.Widget _buildHeader(Invoice invoice) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(height: 1 * PdfPageFormat.cm),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildSupplierAddress(invoice.supplier),
              pw.Container(
                height: 50,
                width: 50,
                child: invoice.customQrPath != null
                    ? pw.Image(
                        pw.MemoryImage(File(invoice.customQrPath!).readAsBytesSync()),
                        fit: pw.BoxFit.contain,
                      )
                    : pw.BarcodeWidget(
                        barcode: pw.Barcode.qrCode(),
                        data: invoice.info.number,
                      ),
              ),
            ],
          ),
          pw.SizedBox(height: 1 * PdfPageFormat.cm),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildCustomerAddress(invoice.customer),
              _buildInvoiceInfo(invoice.info),
            ],
          ),
        ],
      );

  static pw.Widget _buildCustomerAddress(Customer customer) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(customer.name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text(customer.address),
          if (customer.phone != null) pw.Text('Phone: ${customer.phone}'),
          if (customer.email != null) pw.Text('Email: ${customer.email}'),
        ],
      );

  static pw.Widget _buildInvoiceInfo(InvoiceInfo info) {
    final paymentTerms = '${info.dueDate.difference(info.date).inDays} days';
    final titles = <String>[
      'Invoice Number:',
      'Invoice Date:',
      'Payment Terms:',
      'Due Date:'
    ];
    final data = <String>[
      info.number,
      _formatDate(info.date),
      paymentTerms,
      _formatDate(info.dueDate),
    ];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: List.generate(titles.length, (index) {
        final title = titles[index];
        final value = data[index];

        return _buildText(title: title, value: value, width: 200);
      }),
    );
  }

  static pw.Widget _buildSupplierAddress(Supplier supplier) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(supplier.name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 1 * PdfPageFormat.mm),
          pw.Text(supplier.address),
          if (supplier.phone != null) pw.Text('Phone: ${supplier.phone}'),
          if (supplier.email != null) pw.Text('Email: ${supplier.email}'),
        ],
      );

  static pw.Widget _buildTitle(Invoice invoice) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'INVOICE',
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 0.8 * PdfPageFormat.cm),
          pw.Text(invoice.info.description),
          pw.SizedBox(height: 0.8 * PdfPageFormat.cm),
        ],
      );

  static pw.Widget _buildInvoice(Invoice invoice) {
    final headers = [
      'Description',
      'Date',
      'Quantity',
      'Unit Price',
      'VAT',
      'Total'
    ];
    final data = invoice.items.map((item) {
      final total = item.unitPrice * item.quantity * (1 + item.vat);

      return [
        item.description,
        _formatDate(item.date),
        '${item.quantity}',
        '${invoice.currencySymbol} ${item.unitPrice}',
        '${item.vat} %',
        '${invoice.currencySymbol} ${total.toStringAsFixed(2)}',
      ];
    }).toList();

    return pw.Table.fromTextArray(
      headers: headers,
      data: data,
      border: null,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerRight,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.centerRight,
        5: pw.Alignment.centerRight,
      },
    );
  }

  static pw.Widget _buildTotal(Invoice invoice) {
    final netTotal = invoice.items
        .map((item) => item.unitPrice * item.quantity)
        .reduce((item1, item2) => item1 + item2);
    final vatPercent = invoice.items.first.vat;
    final vat = netTotal * vatPercent;
    final total = netTotal + vat;

    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Row(
        children: [
          pw.Spacer(flex: 6),
          pw.Expanded(
            flex: 4,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildText(
                  title: 'Net total',
                  value: _formatPrice(netTotal, invoice.currencySymbol),
                  unite: true,
                ),
                _buildText(
                  title: 'Vat ${vatPercent * 100} %',
                  value: _formatPrice(vat, invoice.currencySymbol),
                  unite: true,
                ),
                pw.Divider(),
                _buildText(
                  title: 'Total amount due',
                  titleStyle: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  value: _formatPrice(total, invoice.currencySymbol),
                  unite: true,
                ),
                pw.SizedBox(height: 2 * PdfPageFormat.mm),
                pw.Container(height: 1, color: PdfColors.grey400),
                pw.SizedBox(height: 0.5 * PdfPageFormat.mm),
                pw.Container(height: 1, color: PdfColors.grey400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(Invoice invoice) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Divider(),
          pw.SizedBox(height: 2 * PdfPageFormat.mm),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              _buildSimpleText(title: 'Paypal', value: invoice.supplier.paymentInfo),
              if (invoice.supplier.website != null) ...[
                pw.SizedBox(width: 4 * PdfPageFormat.mm),
                _buildSimpleText(title: 'Web', value: invoice.supplier.website!),
              ],
            ],
          ),
          pw.SizedBox(height: 1 * PdfPageFormat.mm),
          pw.Text(
            'Generated by BIP Scanner',
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
          ),
        ],
      );

  static pw.Widget _buildSimpleText({
    required String title,
    required String value,
  }) {
    final style = pw.TextStyle(fontWeight: pw.FontWeight.bold);

    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Text(title, style: style),
        pw.SizedBox(width: 2 * PdfPageFormat.mm),
        pw.Text(value),
      ],
    );
  }

  static pw.Widget _buildText({
    required String title,
    required String value,
    double width = double.infinity,
    pw.TextStyle? titleStyle,
    bool unite = false,
  }) {
    final style = titleStyle ?? pw.TextStyle(fontWeight: pw.FontWeight.bold);

    return pw.Container(
      width: width,
      child: pw.Row(
        children: [
          pw.Expanded(child: pw.Text(title, style: style)),
          pw.Text(value, style: unite ? style : null),
        ],
      ),
    );
  }

  static String _formatPrice(double price, String symbol) => '$symbol ${price.toStringAsFixed(2)}';
  static String _formatDate(DateTime date) => DateFormat.yMd().format(date);
}
