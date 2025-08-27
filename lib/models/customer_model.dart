class CustomerModel {
  final String id;
  final String name;
  final String phone;
  final String? address; // New field
  final String? imageBase64;

  CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    this.address, // New field
    this.imageBase64,
  });

  // Add copyWith method
  CustomerModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? address,
    String? imageBase64,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      imageBase64: imageBase64 ?? this.imageBase64,
    );
  }
}