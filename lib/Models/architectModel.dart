// lib/Models/architectModel.dart
import 'package:buildbuddy/Models/Professional.dart';

class Architect extends Professional {
  final List<String>? licenses;

  Architect({
    required super.uid,
    super.name,
    super.location,
    super.email,
    super.phoneNumber,
    super.rating,
    super.reviewCount,
    this.licenses,
  }) : super(role: 'Architect');

  factory Architect.fromMap(Map<String, dynamic> map) {
    return Architect(
      uid: map['uid'] ?? '',
      name: map['displayName'] ?? '',
      location: map['location'] as String?,
      email: map['email'] as String?,
      phoneNumber: map['phoneNumber'] as String?,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (map['reviewCount'] as int?) ?? 0,
      licenses: (map['licenses'] as List<dynamic>?)?.cast<String>(),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'licenses': licenses,
    };
  }

  @override
  Architect copyWith({
    String? uid,
    String? name,
    String? location,
    String? email,
    String? phoneNumber,
    double? rating,
    int? reviewCount,
    String? role, // Required to match Professional.copyWith
    List<String>? licenses, // Additional parameter for Architect
  }) {
    return Architect(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      location: location ?? this.location,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      licenses: licenses ?? this.licenses,
    );
  }
}