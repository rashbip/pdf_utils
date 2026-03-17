import 'customer.dart';
import 'supplier.dart';

/// Main model representing a complete invoice document.
class Invoice {
  /// Metadata about the invoice (number, dates, etc.).
  final InvoiceInfo info;
  /// Information about the entity issuing the invoice.
  final Supplier supplier;
  /// Information about the recipient.
  final Customer customer;
  /// List of line items in the invoice.
  final List<InvoiceItem> items;
  /// Currency symbol to display (defaults to '$').
  final String currencySymbol;
  /// Optional path to a custom QR code or logo image.
  final String? customQrPath;

  const Invoice({
    required this.info,
    required this.supplier,
    required this.customer,
    required this.items,
    this.currencySymbol = '\$',
    this.customQrPath,
  });
}

/// Metadata and identification for an invoice.
class InvoiceInfo {
  /// A brief summary or terms of the invoice.
  final String description;
  /// Unique identifier or serial number for the invoice.
  final String number;
  /// The date the invoice was issued.
  final DateTime date;
  /// The date by which payment is expected.
  final DateTime dueDate;

  const InvoiceInfo({
    required this.description,
    required this.number,
    required this.date,
    required this.dueDate,
  });
}

/// Represents a single line item in an invoice.
class InvoiceItem {
  /// Name or description of the product/service.
  final String description;
  /// Date associated with the line item.
  final DateTime date;
  /// Number of units.
  final int quantity;
  /// Value Added Tax rate (e.g., 0.15 for 15%).
  final double vat;
  /// Price per single unit.
  final double unitPrice;

  const InvoiceItem({
    required this.description,
    required this.date,
    required this.quantity,
    required this.vat,
    required this.unitPrice,
  });
}
