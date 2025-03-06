import 'package:firebase_database/firebase_database.dart';

class Order {
  final String id;
  final String contractorId;
  final String vendorId;
  final String material;
  final int quantity;
  final double price;
  final String status;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.contractorId,
    required this.vendorId,
    required this.material,
    required this.quantity,
    required this.price,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'contractorId': contractorId,
    'vendorId': vendorId,
    'material': material,
    'quantity': quantity,
    'price': price,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Order.fromMap(Map<String, dynamic> map, {required String id}) {
    return Order(
      id: id,
      contractorId: map['contractorId'] as String,
      vendorId: map['vendorId'] as String,
      material: map['material'] as String,
      quantity: map['quantity'] as int,
      price: map['price'] as double,
      status: map['status'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}