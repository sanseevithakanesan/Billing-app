// lib/models/customer.dart
class Customer {
  final int id;
  final String name;
  final String phone;
  final String? email;
  final String? address;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.address,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id:      json['id'],
      name:    json['name'],
      phone:   json['phone'],
      email:   json['email'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id':      id,
    'name':    name,
    'phone':   phone,
    'email':   email,
    'address': address,
  };
}