import 'package:firebase_database/firebase_database.dart';

class Order {
  final String id;
  final String contractorId;
  final String vendorId;
  final String material;
  final String materialId;
  final int quantity;
  final double amount;
  late final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Order({
    required this.id,
    required this.contractorId,
    required this.vendorId,
    required this.material,
    required this.materialId,
    required this.quantity,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'contractorId': contractorId,
    'vendorId': vendorId,
    'material': material,
    'materialId': materialId,
    'quantity': quantity,
    'amount': amount,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
    if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
  };

  factory Order.fromMap(Map<String, dynamic> map, {required String id}) {
    return Order(
      id: id,
      contractorId: map['contractorId'] as String? ?? '',
      vendorId: map['vendorId'] as String? ?? '',
      material: map['material'] as String? ?? '',
      materialId: map['materialId'] as String? ?? '',
      quantity: map['quantity'] as int? ?? 0,
      amount: (map['amount'] is int)
          ? (map['amount'] as int).toDouble()
          : (map['amount'] as double? ?? 0.0),
      status: map['status'] as String? ?? 'Pending',
      createdAt: DateTime.parse(map['createdAt'] as String? ?? DateTime.now().toIso8601String()),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt'] as String) : null,
    );
  }
}