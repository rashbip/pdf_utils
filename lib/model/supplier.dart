/// Represents the company or individual issuing the invoice.
class Supplier {
  /// The business name of the supplier.
  final String name;
  /// The business address of the supplier.
  final String address;
  /// Payment instructions (e.g., bank account, PayPal).
  final String paymentInfo;
  /// Optional contact phone number.
  final String? phone;
  /// Optional contact email address.
  final String? email;
  /// Optional business website URL.
  final String? website;

  const Supplier({
    required this.name,
    required this.address,
    required this.paymentInfo,
    this.phone,
    this.email,
    this.website,
  });
}
