class Supplier {
  final String name;
  final String address;
  final String paymentInfo;
  final String? phone;
  final String? email;
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
