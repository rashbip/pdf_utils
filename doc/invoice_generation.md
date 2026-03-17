# Invoice Generation

The `pdf_utils` plugin provides a powerful and easy-to-use engine for generating professional PDF invoices.

## Overview

Invoice generation is handled by the `PdfInvoiceGenerator` class. It takes an `Invoice` model and returns a `File` object pointing to the generated PDF.

## Models

### Invoice
The root model that aggregates all data:
- `info`: Metadata like number and dates.
- `supplier`: Your company information.
- `customer`: The recipient's information.
- `items`: A list of product or service entries.
- `currencySymbol`: (Optional) Defaults to `$`.
- `customQrPath`: (Optional) Path to a custom QR code or logo.

## Basic Usage

```dart
import 'package:pdf_utils/pdf_utils.dart';

void generateMyInvoice() async {
  final invoice = Invoice(
    supplier: Supplier(
      name: 'My Awesome Company',
      address: '123 Business Lane, City',
      paymentInfo: 'PayPal: pay@awesome.com',
    ),
    customer: Customer(
      name: 'John Doe',
      address: '789 Residential St, Town',
    ),
    info: InvoiceInfo(
      date: DateTime.now(),
      dueDate: DateTime.now().add(Duration(days: 7)),
      description: 'Consulting Services',
      number: 'INV-2024-001',
    ),
    items: [
      InvoiceItem(
        description: 'App Development',
        date: DateTime.now(),
        quantity: 1,
        vat: 0.15,
        unitPrice: 5000.00,
      ),
    ],
  );

  final file = await PdfInvoiceGenerator.generate(invoice);
  print('Invoice saved to: ${file.path}');
}
```

## Customizing the Look

- **QR Codes**: By default, the generator creates a QR code containing the invoice number. You can provide a `customQrPath` to use your own image or logo instead.
- **Currency**: Set `currencySymbol` to your local currency (e.g., `৳` for BDT).
- **VAT**: Each item can have a different VAT rate. The generator will calculate the totals automatically.
