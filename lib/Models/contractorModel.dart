import 'package:buildbuddy/Models/Professional.dart';

class Contractor extends Professional {
  final List<String>? certifications;

  Contractor({
    required super.uid,
    super.name,
    super.location,
    super.email,
    super.phoneNumber,
    super.rating,
    super.reviewCount,
    this.certifications,
  }) : super(role: 'Contractor');

  factory Contractor.fromMap(Map<String, dynamic> map) {
    return Contractor(
      uid: map['uid'] ?? '',
      name: map['displayName'] ?? '',
      location: map['location'] as String?,
      email: map['email'] as String?,
      phoneNumber: map['phoneNumber'] as String?,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (map['reviewCount'] as int?) ?? 0,
      certifications: (map['certifications'] as List<dynamic>?)?.cast<String>(),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'certifications': certifications,
    };
  }

  @override
  Contractor copyWith({
    String? uid,
    String? name,
    String? location,
    String? email,
    String? phoneNumber,
    double? rating,
    int? reviewCount,
    String? role,
    List<String>? certifications,
  }) {
    return Contractor(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      location: location ?? this.location,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      certifications: certifications ?? this.certifications,
    );
  }
}