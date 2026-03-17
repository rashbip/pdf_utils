/// Represents the recipient of the invoice.
class Customer {
  /// The full name of the customer.
  final String name;
  /// The billing address of the customer.
  final String address;
  /// Optional contact phone number.
  final String? phone;
  /// Optional contact email address.
  final String? email;

  const Customer({
    required this.name,
    required this.address,
    this.phone,
    this.email,
  });
}
