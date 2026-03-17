class Customer {
  final String name;
  final String address;
  final String? phone;
  final String? email;

  const Customer({
    required this.name,
    required this.address,
    this.phone,
    this.email,
  });
}
