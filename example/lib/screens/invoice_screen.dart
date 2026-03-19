import 'package:flutter/material.dart';
import 'package:pdf_utils/pdf_utils.dart';
import 'package:open_filex/open_filex.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  String? _statusMessage;

  Future<void> _generateInvoice() async {
    setState(() => _statusMessage = 'Generating Invoice...');
    try {
      final invoice = Invoice(
        supplier: const Supplier(
          name: 'BIP Scanner',
          address: '123 Tech Street, Silicon Valley',
          paymentInfo: 'PayPal: pay@bip.com',
          website: 'www.bipscanner.com',
        ),
        customer: const Customer(
          name: 'Happy Client',
          address: '456 User Lane, App City',
        ),
        info: InvoiceInfo(
          date: DateTime.now(),
          dueDate: DateTime.now().add(const Duration(days: 14)),
          description: 'Software Development Services',
          number: 'INV-${DateTime.now().millisecondsSinceEpoch}',
        ),
        items: [
          InvoiceItem(
            description: 'Flutter Plugin Development',
            date: DateTime.now(),
            quantity: 1,
            vat: 0.15,
            unitPrice: 1500.0,
          ),
          InvoiceItem(
            description: 'Testing & Documentation',
            date: DateTime.now(),
            quantity: 2,
            vat: 0.15,
            unitPrice: 250.0,
          ),
        ],
      );

      final file = await PdfInvoiceGenerator.generate(invoice);
      setState(() {
        _statusMessage = 'Invoice generated: ${file.path}';
      });
      await OpenFilex.open(file.path);
    } catch (e) {
      setState(() => _statusMessage = 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Invoice Generation')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'Generate professional PDF invoices with the high-level invoice engine.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _generateInvoice,
              icon: const Icon(Icons.receipt_long),
              label: const Text('Generate & View Invoice'),
            ),
            if (_statusMessage != null) ...[
              const SizedBox(height: 20),
              Text(_statusMessage!, textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }
}
