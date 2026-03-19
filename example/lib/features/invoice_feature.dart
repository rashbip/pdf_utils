import 'package:flutter/material.dart';
import 'package:pdf_utils/pdf_utils.dart';
import 'package:open_filex/open_filex.dart';

class InvoiceFeature extends StatefulWidget {
  final Function(String) onStatusChange;
  const InvoiceFeature({super.key, required this.onStatusChange});

  @override
  State<InvoiceFeature> createState() => _InvoiceFeatureState();
}

class _InvoiceFeatureState extends State<InvoiceFeature> {
  Future<void> _generateInvoice() async {
    widget.onStatusChange('Generating Invoice...');
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
      widget.onStatusChange('Invoice generated: ${file.path}');
      await OpenFilex.open(file.path);
    } catch (e) {
      widget.onStatusChange('Error generating invoice: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildFeatureCard(
      title: 'Professional Invoice',
      description: 'Generate high-quality PDF invoices from data.',
      icon: Icons.receipt_long,
      onPressed: _generateInvoice,
      color: Colors.blue.shade50,
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      color: color,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Colors.blue.shade700),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(description, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
